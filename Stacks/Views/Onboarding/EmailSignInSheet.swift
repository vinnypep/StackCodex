import SwiftUI

struct EmailSignInSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isSubmitting = false

    let onSubmit: (String) async -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .submitLabel(.continue)
                        .onSubmit { submit() }
                }

                Section {
                    Button {
                        submit()
                    } label: {
                        HStack {
                            Text(isSubmitting ? "Sending" : "Continue")
                            Spacer()
                            if isSubmitting {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isSubmitting)
                }
            }
            .navigationTitle("Continue with Email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func submit() {
        guard !isSubmitting else { return }
        isSubmitting = true
        Task {
            await onSubmit(email)
            isSubmitting = false
            dismiss()
        }
    }
}

