//
//  AsyncGiffy.swift
//  
//
//  Created by Tomas Martins on 27/04/23.
//

import os
import SwiftUI

/// A SwiftUI view that can display an animted GIF image from a remote URL. To present an GIF image that is stored locally, use the ``Giffy`` component instead.
public struct AsyncGiffy<Content: View>: View {
    @ViewBuilder
    private let content: (AsyncGiffyPhase) -> Content
    @State private var phase: AsyncGiffyPhase = .loading
    
    @Binding var url: URL

    private let logger = Logger(
        subsystem: "Giffy",
        category: String(describing: AsyncGiffy.self)
    )
    
    /// Creates a view that presents an animted GIF image from a remote URL to be displayed in phases
    /// - Parameters:
    ///   - url: The remote URL of an animated GIF image to be displayed
    ///   - content: A closure that takes the current phase as an input and returns the view to be displayed in each phase
    public init(url: Binding<URL>,
                @ViewBuilder content: @escaping (AsyncGiffyPhase) -> Content) {
        self.content = content
        self._url = url
    }
    
    public var body: some View {
        content(phase)
            .onAppear {
                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        let view = Giffy(imageData: data)
                        self.phase = .success(view)
                    } catch {
                        logger.warning("Could not get data for GIF file located at \(url.absoluteString)")
                        self.phase = .error
                    }
                }
            }
    }
}
