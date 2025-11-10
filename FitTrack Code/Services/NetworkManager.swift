//
//  NetworkManager.swift
//  FitTrack Code
//
//  Network layer for communicating with backend API
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError:
            return "Failed to decode server response"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Session expired. Please login again."
        }
    }
}

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    // IMPORTANT: Change this to your computer's IP address when testing on a real device
    // Find your IP: Mac -> System Settings -> Network -> Your connection -> Details -> TCP/IP
    // For simulator, you can use "localhost"
    private let baseURL = "http://localhost:8080/api/v1"
    
    @Published var authToken: String? {
        didSet {
            if let token = authToken {
                UserDefaults.standard.set(token, forKey: "authToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "authToken")
            }
        }
    }
    
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    
    private init() {
        // Load saved token on init
        self.authToken = UserDefaults.standard.string(forKey: "authToken")
        self.isAuthenticated = authToken != nil
    }
    
    // MARK: - Generic Request Method
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if required
        if requiresAuth, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        // Check for errors
        if httpResponse.statusCode == 401 {
            // Clear auth token
            await MainActor.run {
                self.authToken = nil
                self.currentUser = nil
                self.isAuthenticated = false
            }
            throw NetworkError.unauthorized
        }
        
        if httpResponse.statusCode >= 400 {
            // Try to decode error message
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.error)
            }
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
        
        // Decode response
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Authentication
    
    func register(email: String, password: String) async throws -> AuthResponse {
        let body = RegisterRequest(email: email, password: password)
        let data = try JSONEncoder().encode(body)
        
        let response: AuthResponse = try await request(
            endpoint: "/auth/register",
            method: "POST",
            body: data
        )
        
        await MainActor.run {
            self.authToken = response.token
            self.currentUser = response.user
            self.isAuthenticated = true
        }
        
        return response
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        let data = try JSONEncoder().encode(body)
        
        let response: AuthResponse = try await request(
            endpoint: "/auth/login",
            method: "POST",
            body: data
        )
        
        await MainActor.run {
            self.authToken = response.token
            self.currentUser = response.user
            self.isAuthenticated = true
        }
        
        return response
    }
    
    func logout() {
        authToken = nil
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - Workouts
    
    func syncWorkout(_ workout: WorkoutSyncRequest) async throws {
        let data = try JSONEncoder().encode(workout)
        
        let _: WorkoutSyncResponse = try await request(
            endpoint: "/workouts",
            method: "POST",
            body: data,
            requiresAuth: true
        )
    }
    
    func fetchWorkouts() async throws -> [WorkoutResponse] {
        return try await request(
            endpoint: "/workouts",
            method: "GET",
            requiresAuth: true
        )
    }
    
    func deleteWorkout(id: String) async throws {
        let _: MessageResponse = try await request(
            endpoint: "/workouts/\(id)",
            method: "DELETE",
            requiresAuth: true
        )
    }
}

// MARK: - API Models

struct ErrorResponse: Codable {
    let error: String
}

struct MessageResponse: Codable {
    let message: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct User: Codable, Identifiable {
    let id: String
    let email: String
}

// Workout sync models
struct WorkoutSyncRequest: Codable {
    let workoutName: String
    let workoutDate: Date
    let durationHours: Int
    let durationMinutes: Int
    let overallRPE: Double
    let estimatedCalories: Int
    let activityType: String
    let exercises: [ExerciseSyncRequest]
    
    enum CodingKeys: String, CodingKey {
        case workoutName = "workout_name"
        case workoutDate = "workout_date"
        case durationHours = "duration_hours"
        case durationMinutes = "duration_minutes"
        case overallRPE = "overall_rpe"
        case estimatedCalories = "estimated_calories"
        case activityType = "activity_type"
        case exercises
    }
}

struct ExerciseSyncRequest: Codable {
    let name: String
    let notes: String
    let order: Int
    let sets: [SetSyncRequest]
}

struct SetSyncRequest: Codable {
    let weight: String
    let reps: String
    let rpe: Double?
}

struct WorkoutSyncResponse: Codable {
    let id: String
    let message: String
}

struct WorkoutResponse: Codable {
    let id: String
    let userId: String
    let workoutName: String
    let workoutDate: Date
    let durationHours: Int
    let durationMinutes: Int
    let overallRPE: Double
    let estimatedCalories: Int
    let activityType: String
    let exercises: [ExerciseResponse]
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case workoutName = "workout_name"
        case workoutDate = "workout_date"
        case durationHours = "duration_hours"
        case durationMinutes = "duration_minutes"
        case overallRPE = "overall_rpe"
        case estimatedCalories = "estimated_calories"
        case activityType = "activity_type"
        case exercises
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ExerciseResponse: Codable {
    let id: String
    let workoutId: String
    let name: String
    let notes: String
    let order: Int
    let sets: [SetResponse]
    
    enum CodingKeys: String, CodingKey {
        case id
        case workoutId = "workout_id"
        case name
        case notes
        case order
        case sets
    }
}

struct SetResponse: Codable {
    let id: String
    let exerciseId: String
    let weight: String
    let reps: String
    let rpe: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case exerciseId = "exercise_id"
        case weight
        case reps
        case rpe
    }
}

