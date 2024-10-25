import SwiftUI

extension EnvironmentValues
{
    @Entry var formWidth: CGFloat = 400
}

extension ContainerValues
{
    @Entry var hasLabel = false
}

public struct CustomFormStyle: FormStyle
{
    static let backgroundColor = Color(red: 1/255*244, green: 1/255*239, blue: 1/255*238)
    static let sectionBackgroundColor = Color(red: 1/255*240, green: 1/255*235, blue: 1/255*234)
    static let borderColor = Color(red: 1/255*230, green: 1/255*225, blue: 1/255*224)
    
    let shouldIndentAllContent: Bool
    
    public init(shouldIndentAllContent: Bool = false)
    {
        self.shouldIndentAllContent = shouldIndentAllContent
    }

    public func makeBody(configuration: Configuration) -> some View
    {
        GeometryReader { geometry in
            ScrollView {
                SectionedContent(shouldIndentAllContent: shouldIndentAllContent) {
                    configuration.content
                        .toggleStyle(.switch)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .labeledContentStyle(CustomLabeledContentStyle())
                }
                .textFieldStyle(ExtractLabelTextFieldStyle())
                .environment(\.formWidth, geometry.size.width)
                .padding()
            }
        }
        .background(Self.backgroundColor)
        .frame(minWidth: 300)
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
    }
}

struct SectionedContent<Content>: View where Content: View
{
    let content: Content
    let shouldIndentAllContent: Bool
    
    init(shouldIndentAllContent: Bool, @ViewBuilder content: () -> Content)
    {
        self.content = content()
        self.shouldIndentAllContent = shouldIndentAllContent
    }
    
    var body: some View {
        ForEach(sections: content) { section in
            if !section.header.isEmpty {
                section.header
                    .fontWeight(.bold)
            }
            VStack(alignment: .center, spacing: 0) {
                Group(subviews: section.content) { subviews in
                    let last = subviews.last?.id
                    ForEach(subviews: subviews) { subview in
                        if shouldIndentAllContent {
                            if subview.containerValues.hasLabel {
                                subview
                            } else {
                                LabeledContent {
                                    subview
                                } label: {
                                    Text("")
                                }
                                .labeledContentStyle(CustomLabeledContentStyle())
                            }
                        } else {
                            subview
                        }
                        if subview.id != last {
                            // Not using `Divider` here, because it does something weird to its foreground style
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(CustomFormStyle.borderColor)
                                .padding(.horizontal, 12)
                                .opacity(1)
                        }
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(CustomFormStyle.sectionBackgroundColor)
                    .stroke(CustomFormStyle.borderColor, lineWidth: 1)
            )
            if !section.footer.isEmpty {
                section.footer
            }
        }
    }
}

struct ExtractLabelTextFieldStyle: @preconcurrency TextFieldStyle
{
    var label: _TextFieldStyleLabel?
    
    @MainActor
    func _body(configuration: TextField<Self._Label>) -> some View
    {
        let mirror = Mirror(reflecting: configuration)
        return Group {
            if let label = mirror.descendant("label") as? _TextFieldStyleLabel {
                FormWidthAwareLabeledContent(label: label, content: configuration)
                    .containerValue(\.hasLabel, true)
            } else {
                configuration
            }
        }
    }
}

struct CustomLabeledContentStyle: LabeledContentStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        FormWidthAwareLabeledContent(label: configuration.label, content: configuration.content)
            .containerValue(\.hasLabel, true)
    }
}

struct FormWidthAwareLabeledContent<Label: View, Content: View> : View
{
    @Environment(\.formWidth) var formWidth
    
    let label: Label
    let content: Content
        
    var body: some View {
        let labelWidth: CGFloat = min(formWidth * 0.3, 200)
        HStack(alignment: .center) {
            label
                .frame(width: labelWidth, alignment: .leading)
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 20)
    }
}

