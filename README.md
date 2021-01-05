# IOS 应用如何更优雅的进行国际化

## iOS应用如何开启国际化

一个应用要支持国际化表示这个应用至少要支持两种及以上的语言，所以需要到项目配置中添加一种额外的语言。
如下图，选择一种语言：

![-w1458](http://img.muliba.net/2021-01-05-16097391302241.jpg)

如我选择了简体中文，它会是否为这些 `storyboard` 创建一个简体中文的本地化配置文件。
![-w767](http://img.muliba.net/2021-01-05-16097392741925.jpg)

完成后 `storyboard` 就会多出一个简体中文的本地化配置文件：
![-w412](http://img.muliba.net/2021-01-05-16097395809270.jpg)

配置文件里面是 `storyboard` 上一些UI组件的文字标识对应的文字内容：

![-w622](http://img.muliba.net/2021-01-05-16097396865756.jpg)

这时候只有一个简体中文的本地化配置文件，选中 `Main.storyboard` 可以在右边的文件监视器上看到当前这个 `storyboard` 有哪些本地化配置文件。
![-w290](http://img.muliba.net/2021-01-05-16097410358417.jpg)
把 `English` 打勾，就会增加一个英文的配置文件。把文件里面的对应的内容改成英文：
![-w810](http://img.muliba.net/2021-01-05-16097411750995.jpg)

这样 `storyboard` 的简体中文、英文双语言支持就做好了。


|   |   |
|---|---|
|   ![-w492](http://img.muliba.net/2021-01-05-16097412801143.jpg)  | ![-w492](http://img.muliba.net/2021-01-05-16097413450211.jpg)  |


### swift 文件中字符串的多语言支持
上面介绍了iOS支持多语言的开启方式，但只有 `storyboard` 上的说明。实际开发中，swift源文件中肯定有很多用到文字的地方，这些地方如何支持多语言。
需要先创建一个 `Localizable.strings` 的文件，然后同 storyboard 一样，添加语言对应的本地配置文件：
![-w2587](http://img.muliba.net/2021-01-05-16097418591281.jpg)

![-w327](http://img.muliba.net/2021-01-05-16097418721277.jpg)

![-w424](http://img.muliba.net/2021-01-05-16097418979081.jpg)

然后就是使用，比如我需要给一个UILabel修复内容：

```swift
//原来的写法
self.helloLabel.text = "我变了"
// 现在用 NSLocalizedString 读取 Localizable.strings 文件中的配置
// first.hello_change 就是配置文件中的 key
self.helloLabel.text = NSLocalizedString("first.hello_change", comment: "")
```

Localizable.strings (English):
```
"first.hello_change" = "I've changed";
```

Localizable.strings (Chinese(Simplified)):
```
"first.hello_change" = "我变了";
```
 展现效果：
 

|   |   |
|---|---|
| ![-w492](http://img.muliba.net/2021-01-05-16097430929809.jpg)|  ![-w492](http://img.muliba.net/2021-01-05-16097427670536.jpg) |
  
  
> 现有的问题：刚才上面演示的时候，新增加了一个** 修复内容** 的按钮，这个是后来加到 storyboard 上去的，它的文字没有随着语言环境的变化进行变更。看看  `Main.storyboard` 的两个本地化配置文件你会发现，新增加的控件不会有对应字符串的键增加到本地化配置文件中。这个在开发过程中相当麻烦，只要 `storyboard` 增加删除有文本内容的UI组件，你就得到对应的本地化配置文件中去添加删除多语言字符串的键。



##  在本地化配置文件中自动生成字符串的键

这时候就需要借助工具来帮助我们了。一个 GitHub上的开源库 [BartyCrouch](https://github.com/Flinesoft/BartyCrouch)  。这个工具非常强大，不仅可以帮助我们自动生成 storyboard 上UI控件字符串的键到本地化配置文件中，还能把 Swift 源文件中 `NSLocalizedString` 的键写入到 `Localizable.strings` 的各个语言文件中。

首先要本地安装：

```shell
brew install bartycrouch
```

然后到我们的iOS项目根目录下初始化：

```shell
bartycrouch init
```
完成后继续执行命令：

```shell
bartycrouch update -x
```

这样就会把storyboard中的新加的控件需要多语言的键值对写入到本地化配置文件中了，不需要我们手工添加。但是每次执行命令也很麻烦，这里就用到xcode的脚本配置。
![-w1747](http://img.muliba.net/2021-01-05-16097468921931.jpg)

脚本内容：

```shell
if which bartycrouch > /dev/null; then
    bartycrouch update -x
    bartycrouch lint -x
else
    echo "warning: BartyCrouch not installed, download it from https://github.com/Flinesoft/BartyCrouch"
fi

```
把这个脚本放到 Compile Sources 前面，在编译之前，先把键值对生成好。
![-w1480](http://img.muliba.net/2021-01-05-16097469498681.jpg)

然后只要 ` Command + B ` ，就会执行这个脚本，并生成键值对，下面那句` bartycrouch lint -x` 使用来检查本地化配置文件的，是否有空值，是否有重复的键 等等。



> 上面的命令同时会把 Swift 源文件中的字符串也能生成对应的键到 `Localizable.strings` 文件中，只要你源文件中的字符串是用 `NSLocalizedString` 函数生成的就行。

### BartyCrouch.swift

[BartyCrouch](https://github.com/Flinesoft/BartyCrouch)  还有转化代码的一个功能，上面说的 Swift 源文件中 多语言的字符串写法是：

```swift
self.helloLabel.text = NSLocalizedString("first.hello_change", comment: "我变了")
```

 [BartyCrouch](https://github.com/Flinesoft/BartyCrouch) 提供了一个枚举类：
 
```swift
enum BartyCrouch {
    enum SupportedLanguage: String {
        // TODO: remove unsupported languages from the following cases list & add any missing languages
        
        case chineseSimplified = "zh-Hans"
        case chineseTraditional = "zh-Hant"
        case english = "en"
        case french = "fr"
        case german = "de"
        case hindi = "hi"
        case italian = "it"
        case japanese = "ja"
        case korean = "ko"
        case malay = "ms"
        case portuguese = "pt-BR"
        case russian = "ru"
        case spanish = "es"
        case turkish = "tr"
    }

    static func translate(key: String, translations: [SupportedLanguage: String], comment: String? = nil) -> String {
        let typeName = String(describing: BartyCrouch.self)
        let methodName = #function

        print(
            "Warning: [BartyCrouch]",
            "Untransformed \(typeName).\(methodName) method call found with key '\(key)' and base translations '\(translations)'.",
            "Please ensure that BartyCrouch is installed and configured correctly."
        )

        // fall back in case something goes wrong with BartyCrouch transformation
        return "BC: TRANSFORMATION FAILED!"
    }
}
```

利用这个枚举类，把上面多语言字符串的写法替换一下：

```swift
self.helloLabel.text = BartyCrouch.translate(key: "first.hello_change", translations: [.english: "I`ve changed", .chineseSimplified: "我变了"])
```
这种写法把字符串的key以及对应语言的翻译内容写入代码中。然后执行编译，也就是run 一下 BartyCrouch 的 update 脚本。你会发现上面那段代码又变回这样了：

```swift
self.helloLabel.text = NSLocalizedString("first.hello_change", comment: "")
```

但是我们的` Localizable.strings` 文件中对应的地方有了翻译内容了。


## SwiftGen
继续深化一下，科普下一个好工具。[SwiftGen](https://github.com/SwiftGen/SwiftGen) 这个工具用来解决一个iOS开发中的普遍问题，就是我们写资源的时候用字符串查找的，比如 

```swift
let testImage = UIImage(named: "test")
```
这里用 `test` 字符串去查找对应的图片资源，万一手抖写错了，xcode编译也不会报错。隔壁Android就很方便用一个 `R` 文件管理了所有的资源，`R.drawable.test` ,写错了 IDE 马上就会提示。

针对这个问题，[SwiftGen](https://github.com/SwiftGen/SwiftGen) 就模仿 Android 用枚举类的方式来解决了这个问题。
比如类似这样的代码：

```swift
import UIKit.UIImage

struct ImageAssets {
    fileprivate var name: String
    var image: UIImage {
        let image = UIImage(named: name)
        guard let result = image else { fatalError("Unable to load image named \(name).") }
        return result
    }
}
enum Assets {
    enum AppLogo {
        static let appLogo = ImageAssets(name: "appLogo")
        static let grayLogo = ImageAssets(name: "gray_logo")
    }
    enum Arrow {
        static let arrowBlue = ImageAssets(name: "arrow_blue")
        static let arrowBrown = ImageAssets(name: "arrow_brown")
    }
    // ....
}
extension UIImage {
    convenience init!(asset: ImageAssets) {
        self.init(named: asset.name)
    }
}
```

这样使用的时候就只需要写： 

```swift
let logo = Asset.AppLogo.appLogo.image
```

那上面的多语言的问题也是有同样的问题，` Localizable.strings` 文件里面的 `key` 要和 swift源码里面的一一对应，所以用 SwiftGen 减少错误。

BartyCrouch 本身就支持这个 SwiftGen 工具。

要用 SwiftGen 首先也是要安装一下的：

```shell
brew install swiftgen
```
然后在iOS项目根目录创建一个配置文件` swiftgen.yml` ，内容如下：

```yml
strings:
  inputs: InternationalDemo/zh-Hans.lproj/Localizable.strings
  outputs:
    - templateName: structured-swift5
      output: InternationalDemo/Strings.swift
```
上面的地址自行替换，它这里会根据inputs的本地化配置文件，生成 Strings.swift 的枚举文件。这个 `Strings.swift `文件需要自行创建好，一个空白文件就行。

### 和 BartyCrouch 结合起来
在 BartyCrouch 初始化的时候在项目根目录生成了一个文件 `.bartycrouch.toml` ，里面有一段：

```
[update.transform]
codePaths = ["."]
localizablePaths = ["."]
transformer = "foundation"
supportedLanguageEnumPath = "."
typeName = "BartyCrouch"
translateMethodName = "translate"
```

把里面的 transformer 替换一下内容， 改成：

```
[update.transform]
codePaths = ["."]
localizablePaths = ["."]
transformer = "swiftgenStructured"
supportedLanguageEnumPath = "."
typeName = "BartyCrouch"
translateMethodName = "translate"
```

最后再添加一个自动脚本：
![-w1612](http://img.muliba.net/2021-01-05-16098122277661.jpg)
 这个 `swiftgen` 脚本需要放在 `bartycrouch` 脚本的后面。
 
 最后的效果类似这样：

![1_h5dhPwwxiDsT1n7x3EKg0A](http://img.muliba.net/2021-01-05-1_h5dhPwwxiDsT1n7x3EKg0A.gif)

也就是你只要按照 BartyCrouch 的方式写多语言文本，Cmd + B 运行脚本后，代码就会自动替换成 Swiftgen 生成的枚举模型，当然同时会在多语言本地化配置中添加对应的键和翻译内容。




内容比较多，主要是在iOS多语言的基础上引入了两个强大的工具，特别是 BartyCrouch ，不止有上面提到的那些功能，还有更多强大的功能。

The End !
