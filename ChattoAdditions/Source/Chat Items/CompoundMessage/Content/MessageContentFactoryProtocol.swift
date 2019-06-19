//
// The MIT License (MIT)
//
// Copyright (c) 2015-present Badoo Trading Limited.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Chatto

public protocol MessageContentPresenterProtocol {

    var showBorder: Bool { get }

    func contentWillBeShown()
    func contentWasHidden()
    func contentWasTapped()
}

public final class DefaultMessageContentPresenter: MessageContentPresenterProtocol {

    public typealias ActionHandler = (UIView?) -> Void

    public init(showBorder: Bool,
                onContentWillBeShown: ActionHandler? = nil,
                onContentWasHidden: ActionHandler? = nil,
                onContentWasTapped: ActionHandler? = nil) {
        self.showBorder = showBorder
        self.onContentWillBeShown = onContentWillBeShown
        self.onContentWasHidden = onContentWasHidden
        self.onContentWasTapped = onContentWasTapped
    }

    private weak var view: UIView?

    public let showBorder: Bool
    private let onContentWillBeShown: ActionHandler?
    private let onContentWasHidden: ActionHandler?
    private let onContentWasTapped: ActionHandler?

    public func contentWillBeShown() { self.onContentWillBeShown?(self.view) }
    public func contentWasHidden() { self.onContentWasHidden?(self.view) }
    public func contentWasTapped() { self.onContentWasTapped?(self.view) }

    public func bindTo(view: UIView) {
        self.view = view
    }

    public func unbindFromView() {
        self.view = nil
    }
}

public protocol MessageContentFactoryProtocol {
    associatedtype Model
    var identifier: String { get }
    func canCreateMessageContent(forModel model: Model) -> Bool
    func createContentView() -> UIView
    func createContentPresenter(forModel model: Model) -> MessageContentPresenterProtocol
    func unbindContentPresenter(_ presenter: MessageContentPresenterProtocol)
    func bindContentPresenter(_ presenter: MessageContentPresenterProtocol, withView view: UIView, forModel model: Model)
    func createLayoutProvider(forModel model: Model) -> MessageManualLayoutProviderProtocol
    func createMenuPresenter(forModel model: Model) -> ChatItemMenuPresenterProtocol?
}

public extension MessageContentFactoryProtocol {
    var identifier: String {
        return String(describing: type(of: self))
    }
}

public final class AnyMessageContentFactory<Model>: MessageContentFactoryProtocol {

    private let _canCreateMessageContent: (Model) -> Bool
    private let _createContentView: () -> UIView
    private let _createContentPresenter: (Model) -> MessageContentPresenterProtocol
    private let _unbindContentPresenter: (MessageContentPresenterProtocol) -> Void
    private let _bindContentPresenter: (MessageContentPresenterProtocol, UIView, Model) -> Void
    private let _createLayoutProvider: (Model) -> MessageManualLayoutProviderProtocol
    private let _createMenuPresenter: (Model) -> ChatItemMenuPresenterProtocol?

    public init<U: MessageContentFactoryProtocol>(_ base: U) where U.Model == Model {
        self.identifier = base.identifier
        self._canCreateMessageContent = base.canCreateMessageContent
        self._createContentView = base.createContentView
        self._createContentPresenter = base.createContentPresenter
        self._unbindContentPresenter = base.unbindContentPresenter
        self._bindContentPresenter = base.bindContentPresenter
        self._createLayoutProvider = base.createLayoutProvider
        self._createMenuPresenter = base.createMenuPresenter
    }

    public let identifier: String

    public func canCreateMessageContent(forModel model: Model) -> Bool {
        return self._canCreateMessageContent(model)
    }

    public func createContentView() -> UIView {
        return self._createContentView()
    }

    public func createContentPresenter(forModel model: Model) -> MessageContentPresenterProtocol {
        return self._createContentPresenter(model)
    }

    public func unbindContentPresenter(_ presenter: MessageContentPresenterProtocol) {
        return self._unbindContentPresenter(presenter)
    }

    public func bindContentPresenter(_ presenter: MessageContentPresenterProtocol, withView view: UIView, forModel model: Model) {
        return self._bindContentPresenter(presenter, view, model)
    }

    public func createLayoutProvider(forModel model: Model) -> MessageManualLayoutProviderProtocol {
        return self._createLayoutProvider(model)
    }

    public func createMenuPresenter(forModel model: Model) -> ChatItemMenuPresenterProtocol? {
        return self._createMenuPresenter(model)
    }
}
