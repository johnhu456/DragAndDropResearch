# DragAndDropResearch
New 'Drag and drop' feature in iOS11 research demo


以下内容都是自己阅读实践所得，如有误请多指教，谢谢。
（示例代码为Swift，刚学，请多指教）

###Drag and Drop 简单介绍

Drag and Drop是iOS11的一套基于UIKit的新API。它可以让你拖动屏幕上的视图进行一些操作，包括但不限于移动，复制内容。甚至可以在不同App之间进行Drag and drop，就像WWDC上面演示的一样： [Introducing Drag and Drop](https://developer.apple.com/videos/play/wwdc2017/203/)，但是在iPhone上，Drag and Drop仅支持单App。

[Drag and Drop 官方文档](https://developer.apple.com/documentation/uikit/drag_and_drop)

![Drag and Drop](http://upload-images.jianshu.io/upload_images/1683504-805707e7403ea458.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

接下来我将通过几个Demo来讲解如何去简单开发Drag and Drop的应用。
今天这篇文章将讲解如何使用UIView的新属性pasteConfiguration去最简单的实现一个拖动进行粘贴的操作，如图：

![Drag and Drop](http://upload-images.jianshu.io/upload_images/1683504-8733533c7c9f6b7f.gif?imageMogr2/auto-orient/strip)


####Step1 给View添加Drag
**UIDragInteraction & UIDropInteraction**
这两个可以说是Drag'n Drop 开发中最基本的类，都继承自UIInteraction，属性上也基本相同。  
你可以把他们当成UIGestureRecognizer，使用的时候只需要初始化一个UIDragInteraction/UIDropInteraction，设定好delegate，再添加到相应的view即可：
```
        //Add an UIDragInteraction to support drag
        dragImageView.addInteraction(UIDragInteraction.init(delegate: self))
```
此时你的view就可以支持长按进行拖动了（但是在iPhone上同样的代码却不起作用，不知道为什么，明白的小伙伴欢迎解答）

***注意使用的时候需要将view的isUserInteractionEnabled设为true***

####Step2 给目的地上的View添加pasteConfiguration
在本例中我们创建两个UIImageView，一个用来展示原始图片并提供拖动（dragImageView），拖到另一个上（pasteImageView）后，进行粘贴的操作。
这里只需要在dragImageView上添加UIDragInteraction即可，要让pasteImageView支持Drop的话，上文已经说到，最简单的方法就是配置pasteConfiguration属性：
```
pasteImageView.pasteConfiguration = UIPasteConfiguration(forAccepting: UIImage.self)
```
以上代码就是声明pasteImageView支持drop功能，并且你可以把包含UIImage数据的对象拖到这个pasteImageView上来进行粘贴。当然通过配置UIPasteConfiguration，可以支持很多不同的数据类型。
**同时必须重写改view的paste方法，下文详说**

####Step3 实现UIDragInteraction
这时运行demo会发现即时我们在图片上按再长的时间，也没有任何变化，也不能拖动。

因为我们必须提供一个被拖动的对象，当然是数据层面上的，用来告诉系统我们正在拖text呢 还是image呢，以便其他支持Drop的view可以根据数据类型来决定是否能够接收drop。
```
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        if interaction.view == dragImageView {
            let dragImage = dragImageView.image
            let itemProvider = NSItemProvider.init(object: dragImage!)
            let dragItem = UIDragItem.init(itemProvider: itemProvider)
            return [dragItem]
        }
        else if interaction.view == dragTextLabel {
            let dragText = "Try drag me~"
            let itemProvider = NSItemProvider.init(object: dragText as NSString)
            let dragItem = UIDragItem.init(itemProvider: itemProvider)
            return [dragItem]
        }
        else {
           return []
        }
    }
```
这里涉及到两个新类，UIDragItem & NSItemProvider
NSItemProvider简单来说就是用来在Drag and Drop，或者Extension app 和Host app之间传输数据的类。
UIDragItem则是像对NSItemProvider的进一步封装，除了包含传输数据外，还可以自定义一些数据。
具体用法就是如上：
```
            let dragImage = dragImageView.image
            let itemProvider = NSItemProvider.init(object: dragImage!)
            let dragItem = UIDragItem.init(itemProvider: itemProvider)
            return [dragItem]
```
将我们要拖动的Image对象一层层包起来返回即可。

这时再运行demo就发现可以拖动了，而且当图片悬浮在pasteImageView上时可以看到右上角有加号，说明此处支持粘贴的操作，但是鼠标一松开就Crash了。

####Step4 重写Paste
上面的Crash信息显示：
```
Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'pasteItemProviders: must be overridden if pasteConfiguration is not nil.'
```
上文就说必须重写pasteItemProviders。
那我们重写一下pasteImageView的pasteItemProviders方法，让它支持粘贴。
```
    override func paste(itemProviders: [NSItemProvider]) {
        for dragItem in itemProviders {
            if dragItem.canLoadObject(ofClass: UIImage.self) {
                dragItem.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in
                    if image != nil {
                        DispatchQueue.main.async {
                            self.tipLayer.removeFromSuperlayer()
                            self.customBorderLayer.removeFromSuperlayer()
                            self.image = (image as! UIImage)
                        }
                    }
                })
            }
        }
    }
```
以上操作就是先判断这个NSItemProvider是否可以load UIImage这一类的数据，如果可以我们就load出来进行界面更新等操作。
这时再运行一遍应该就可以复制了。

####-----
以上全部就是比较详细的介绍了如何使用view的pasteConfiguration来简单实现Drag to paste，留下一个拖动文字的功能可以自己尝试实现一下。
小提示：textField不用配置pasteConfiguration,自己对于NSString类型的数据有默认实现。

demo地址：[https://github.com/madao1237/DragAndDropResearch](https://github.com/madao1237/DragAndDropResearch)