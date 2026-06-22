import SwiftUI
import UIKit

@MainActor
enum AdPresentationAnchor {
    static weak var viewController: UIViewController?
}

final class AdAnchorViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AdPresentationAnchor.viewController = presentationAnchor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        AdPresentationAnchor.viewController = presentationAnchor
    }

    var presentationAnchor: UIViewController {
        var candidate: UIViewController = self
        while let parent = candidate.parent {
            candidate = parent
        }
        return candidate
    }
}

struct AdPresentationAnchorView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AdAnchorViewController {
        let controller = AdAnchorViewController()
        controller.view.isUserInteractionEnabled = false
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(_ uiViewController: AdAnchorViewController, context: Context) {
        AdPresentationAnchor.viewController = uiViewController.presentationAnchor
    }
}
