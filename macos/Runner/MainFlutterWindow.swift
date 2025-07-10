import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // Set a fixed size similar to an iPhone and center the window.
    let iphoneSize = CGSize(width: 414, height: 896)
    self.setContentSize(iphoneSize)
    
    if let screen = NSScreen.main {
      let screenRect = screen.visibleFrame
      let windowRect = self.frame
      let newOrigin = NSPoint(
        x: (screenRect.width - windowRect.width) / 2,
        y: (screenRect.height - windowRect.height) / 2
      )
      self.setFrameOrigin(newOrigin)
    }

    // Disable window resizing to maintain the aspect ratio.
    self.styleMask.remove(.resizable)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
