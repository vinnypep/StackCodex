import MobileCoreServices
import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        captureSharedLink()
    }

    private func captureSharedLink() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = item.attachments,
              let provider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) || $0.hasItemConformingToTypeIdentifier(kUTTypeURL as String) }) else {
            complete()
            return
        }

        let title = item.attributedTitle?.string ?? item.attributedContentText?.string
        let typeIdentifier = provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) ? UTType.url.identifier : kUTTypeURL as String
        provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { [weak self] item, _ in
            guard let self else { return }

            let url: URL?
            if let sharedURL = item as? URL {
                url = sharedURL
            } else if let text = item as? String {
                url = URL(string: text)
            } else {
                url = nil
            }

            if let url {
                try? PendingSharedLinkStore.save(PendingSharedLink(url: url, title: title))
            }

            DispatchQueue.main.async {
                self.openContainingApp()
            }
        }
    }

    private func openContainingApp() {
        extensionContext?.open(SharedImportConfiguration.callbackURL) { [weak self] _ in
            self?.complete()
        }
    }

    private func complete() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
