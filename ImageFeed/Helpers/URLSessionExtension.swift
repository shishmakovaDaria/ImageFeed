import Foundation

private enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completiion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletion: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completiion(result)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { fulfillCompletion(.failure(NetworkError.urlRequestError(error))) }
            guard let data = data,
                let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
                return
            }
            
            if 200 ..< 300 ~= statusCode {
                do {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    fulfillCompletion(.success(object))
                } catch {
                    fulfillCompletion(.failure(error))
                }
            } else { fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode))) }
        }
        return task
    }
}
