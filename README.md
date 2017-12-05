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





# Drag and Drop for iOS11 (Drag to Move/Copy)

在上一篇文章中我们已经实现了用UIDragInteraction 和UIView的新属性pasteConfiguration实现了简单的拖动粘贴操作。
以下我们将继续深入一点研究Drag and Drop 并实现拖动换位置和拖动进行Copy功能，
如图：
![Drag to Move/Copy](http://upload-images.jianshu.io/upload_images/1683504-949c4164f493aad3.gif?imageMogr2/auto-orient/strip)

与之前简单使用pasteConfiguration不同，此次我们要自己来同时实现几个UIDragInteractionDelegate和UIDropInteractionDelegate的关键方法。

###Drag to move 
####Step 0 TimeLine 
![Drag and Drop Timeline](http://upload-images.jianshu.io/upload_images/1683504-1862b595f629704d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)  
首选了解一下Drag and Drop 的生命周期，如上图。
当你长按住一个视图的时候，视图升起时候Drag就开始了，然后随着手指的移动这一段都是Drag, 一旦松开手指，就由Drop来接管了，继续进行一些动画或者数据传输等操作，这应该比较好理解，所以先处理Drag啦。

####Step1 给View添加Drag和Drop
这部分关于UIDragInteraction&UIDropInteraction的上一篇文章[Drag and Drop for iOS11](http://www.jianshu.com/p/2caa9b861121)已经介绍过。
我们创建一个ImageView来支持drag, 同时也要让当前的父view支持drop：
```
       //Config for drag image
        let dragImage = UIImage.init(named: "madao")
        dragImageView = UIImageView.init(frame: CGRect.init(x: 50, y: 80, width: kImageSizeWidth, height: kImageSizeHeight))
        dragImageView.isUserInteractionEnabled = true
        dragImageView.backgroundColor = UIColor.clear
        dragImageView.image = dragImage
        dragImageView.clipsToBounds = true
        dragImageView.contentMode = .scaleAspectFill
        
        //Add an UIDragInteraction to support drag
        dragImageView.addInteraction(UIDragInteraction.init(delegate: self))
        view.addSubview(dragImageView)
        
        //Add UIDropInteraction to support drop
        view.addInteraction(UIDropInteraction.init(delegate: self))
```

####Step2 实现DragInteractionDelegate
最重要的，就像UITableView中的dataSource一样，我们提供可以拖动的数据源：
```
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let dragImage = dragImageView.image
        //使用该图片作为拖动的数据源，由NSItemProvider负责包装
        let itemProvider = NSItemProvider.init(object: dragImage!)
        let dragItem = UIDragItem.init(itemProvider: itemProvider)
        return [dragItem]
    }
```

####Step3 实现DropInteractionDelegate
首先类似itemsForBeginning方法在UIDragInteractionDelegate中的重要地位一样，要想一个view能够响应一个Drop,我们需要实现：
```
func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal
```
该代理方法当你手指在view上拖动的时候会响应，意义在于告诉view，drop是什么类型的。主要是以下这几种：
![Drop proposal](http://upload-images.jianshu.io/upload_images/1683504-e94655f22e6cb06e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

*  **cancel**： 不响应Drop动作，应该可以理解成无视。
*  **copy**：拷贝，右上角会显示+号，当然拷贝的操作是要我们自己配合delegate来完成
*  **move**：虽然看上去和cancel一模一样，但是程序中还是会判定视图可以响应这个drop事件，同样，我们也要在delegate中完成相应代码来使他“看上去”像一个move的动作
*  **forbidden**:表示该视图支持drop,但是当前暂时不支持响应（有任务block住了或者文件类型不支持之类的）

总之我们需要在上面那个delegate中告诉这个view该如何响应drop,如下：
```
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
         //原程序设计通过segmentControl来选择操作，所以这里通过判断来返回不同的UIDropProposal，如果单纯为了实现Move功能，也可以直接返回UIDropProposal.init(operation: UIDropOperation.move)
        let operation = segmentControl.selectedSegmentIndex == 0 ? UIDropOperation.move : .copy
        let proposal = UIDropProposal.init(operation: operation)
        dropPoint = session.location(in: view)
        return proposal
    }
```

然后我们实现performDrop：
```
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        //我们这里可以获取到dropSession在视图中的位置，然后就可以将ImageView直接移动到那个点。
        let dropPoint = session.location(in: interaction.view!)
        self.selectedImageView.center = dropPoint
    }
```

####Take a break
以上步骤完成后，运行后应该可以看到我们已经简单实现了一个Drag to move的功能，虽然可能相比使用手势会稍显麻烦，但是苹果提供的动画让他显得更炫酷。

####Step4 动画
UIDragInteractionDelegate和UIDropInteractionDelegate也提供给我们了一些很好的方法让在Drag 和Drop的timeline中执行我们自己的动画，
这里举一个例子：
```
    func dropInteraction(_ interaction: UIDropInteraction, item: UIDragItem, willAnimateDropWith animator: UIDragAnimating) {
        if segmentControl.selectedSegmentIndex == 0 {
            //Move，使用提供的参数animator去添加我们想要的动画
            animator.addAnimations {
                self.selectedImageView.center = self.dropPoint!
            }
            animator.addCompletion { _ in
                self.selectedImageView.center = self.dropPoint!
            }
        }
```
还是蛮方便的，以上就是Drag to move 的实现。

###Drag to copy
其实和上文的Drag to move几乎一模一样，都是实现几个关键的delegate方法（可以复习一下哪几个delegate方法必须要实现）和锦上添花的动画方法。
不一样的就是需要传输数据。
可能有人会说 那我在performDrop的时候直接把imageView 复制到新位置不就好了么，虽然这样可以，但是也失去了Drag and Drop这个功能使用的意义。

我觉得它的意义更在于底层看不见的数据随着手指的流动，因为Drag and drop 不止于在自己的App内进行传输。

前文我们说到在Drag中需要用NSItemProvider来包装这个image，同样在Drop中我们也要使用NSItemProvider来解开这个数据并进行展示，直接贴代码：
```
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        self.dropPoint = session.location(in: interaction.view!)
        //Must implement this method
        if session.localDragSession == nil {
            self.dropPoint = session.location(in: interaction.view!)
                for dragItem in session.items { 
                    //从传过来的dragItem中获取数据的NSItemProvider
                    createImageFromProviderAndPoint(provider: dragItem.itemProvider, point: self.dropPoint!)
                }
        } else {
            self.selectedImageView.center = self.dropPoint!
        }
    }
    private func createImageFromProviderAndPoint(provider:NSItemProvider, point:CGPoint) {
        //创建一个新的imageView
        let newImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: kImageSizeWidth, height: kImageSizeHeight))
        newImageView.center = point
        newImageView.isUserInteractionEnabled = true
        newImageView.backgroundColor = UIColor.clear 
        //使用NSItemProvider 直接加载UIImage
        provider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
            //成功后直接显示
            if object != nil {
                DispatchQueue.main.async {
                    newImageView.image = (object as! UIImage)
                    newImageView.addInteraction(UIDragInteraction.init(delegate: self))
                    self.view.addSubview(newImageView)
                }
            }
            else {
                // Handle the error
            }
        })
    }

```
当然前面的proposal也要返回copy，这样在拖动时，视图的右上角才会显示+号。
当你完成以上代码之后，应该就可以Drag to copy了。

**在iPad分屏模式下，来回拖动相册的照片到这个demo里面或者把demo的图片拖到系统相册也是可以的哦，这要归功于强大的delegates和NSItemProvider**

**-----**
demo地址：[https://github.com/madao1237/DragAndDropResearch](https://github.com/madao1237/DragAndDropResearch)



#Drag and Drop for iOS11 (Drag to transport)

   之前两篇笔记都是讲的如何在一个App内创建及使用Drag&Drop， 在自己的App中集成这些新特性可以丰富交互效果， 起码不用自己写一套拖拽了。
  但是如果能在不同App之间建立起Drag&Drop，事情就会更方便了， 运用好的话整体的操作体验就会上一个Level。

如图是演示demo的效果：
![Drag to transport](http://upload-images.jianshu.io/upload_images/1683504-70e5692a557499ad.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

主要分两部分来介绍怎么实现拖拽来传输数据吧。

####Drag 
第一部分是将自己App内的对象Drag 出去。

其实只要添加了DragInteraction的UIView对象都可以在UI上拖到别的App内，但是如果没有指定拖拽的数据类型或者数据加载的方式，那别的App也是无法正常读出你正在拖拽的数据信息的。  

#####Step 0 给UITableView 添加drag手势
在前两篇笔记中我们提到想要让视图对象可以拖拽就需要添加一个UIDragInteraction，但是在针对TableView或者CollectionView这样的表格视图时就不用那么麻烦了。苹果已经为我们提供了
**UITableViewDragDelegate,  
 UITableViewDropDelegate,  
UICollectionViewDragDelegate  
UICollectionViewDropDelegate**。

这四个protocol中基本都包含了之前介绍过的UIDragInteractionDelegate,UIDropInteractionDelegate的交互方法，并针对TableView和CollectionView做了优化，用起来就像实现它们的DataSource一样简单。
为了实现拖拽，你需要给每个支持拖拽的cell返回一个UIDragItem，实现： 

```` func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] ````

实现上述代理后，虽然发现tableView中的Cell可以拖动了。

####Setp1 注册数据类型及加载器
但是怎么才能让别的App知道我拖动的是什么类型的数据或者别人该如何获得我的数据呢？
对于简单的Image或者Text数据，建议使用之前提到过的：
````
            let itemProvider = NSItemProvider.init(object: dragImage!)
            let dragItem = UIDragItem.init(itemProvider: itemProvider)
````
直接传入需要传输的数据即可，但是类型还是需要遵守协议[NSItemProviderWriting](https://developer.apple.com/documentation/foundation/nsitemproviderwriting)&[NSItemProviderReading](https://developer.apple.com/documentation/foundation/nsitemproviderreading)
简单来说NSItemProviderWriting 是数据提供方需要实现的协议，NSItemProviderReading是数据接收方需要实现的协议。

但是对于很多数据，比如PDF,Video甚至直接一些二进制数据我们是无法用对象来传输数据的，这时候就要用到NSItemProvider 的另一系列Register方法， register的方法有很多：
````
//注册一个以data为基础的数据loader
registerDataRepresentation(forTypeIdentifier:visibility:loadHandler:)  

//注册一个以文件为基础的数据loader
(如果目标App需要使用文件系统来访问数据，可以使用以下方法，返回一个文件的NSURL)
registerFileRepresentation(forTypeIdentifier:fileOptions:visibility:loadHandler:)  

//下面两方法类似，参数不同，都是注册一个遵守NSItemProviderProtocol的对象到ItemProvider中。
registerObject(_:visibility:)
registerObject(ofClass:visibility:loadHandler:)  

//注册比较Custom的对象，只有当目标App能接受的TypeIdentifier和自己所传递的ItemProvider注册的TypeIdentifier一致时会调用到参数中的loadHandler，开发者应该在这个handler中加载好数据并转换成TypeIdentifier相应的格式，最后调用completion，不管是成功还是失败，因为目标App需要这个状态。
registerItem(forTypeIdentifier:loadHandler:)
````

**关于Type Identifer**
以上很多方法都有Type Identifer，其实就是文件的格式，苹果提供的UTI Types来表示文件的格式，比如MP4在UTI Type中就是“public.mpeg-4”，详情可参见这张表:
[System-Declared Uniform Type Identifiers](https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259)

这里选择最后一个RegisterItem方法来传输我们的MP4文件数据
示例代码如下:
````
    //MARK: - UITableViewDragDelegate
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        //初始化过程中的item没那么重要，后面没有使用到过，但是typeIdentifier一定要和想要传输的格式一致，所以这里是UTI标准的
        let itemProvider = NSItemProvider.init(item: videoPlayURLs[indexPath.row] as NSSecureCoding, typeIdentifier: "public.mpeg-4")

        itemProvider.registerItem(forTypeIdentifier: "public.mpeg-4") { (loader, data, option) in
            let request = URLRequest.init(url: self.videoPlayURLs[indexPath.row] as URL)
            let task = URLSession.shared.downloadTask(with: request, completionHandler: { (url, response, error) in
                let videoData = NSData.init(contentsOf: url!)
                //这里加载URL 的数据，并以NSData的形式callback给目标App进行处理。
                loader(videoData,nil)
            })
            task.resume()
        }
        let dragItem = UIDragItem.init(itemProvider: itemProvider)
        return [dragItem]
    }
````

画了一张流程图，希望可以看得更明白一点。
![流程图](http://upload-images.jianshu.io/upload_images/1683504-eda78c691841aa25.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

####Step2 预览图
这个时候虽然已经可以将cell中的视频拖到别的App中，比如iMessage。但是美中不足的是拖动时候悬浮的那个View可能会比较难看，因为默认是将整个cell的contentView提出来作为Drag时候的预览图的，可以通过
```
func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters?
```
来实现自定义的预览

#####UIDragPreviewParameters
该类是专门设计用来调整Drag item的预览图的, 可以通过其中的属性定义自己想要的自定义视图
直接上Code
示例代码：
```
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let targetCell = tableView.cellForRow(at: indexPath) as! DragToTransportCell
        let dragPreviewParam = UIDragPreviewParameters.init()
        //这里使用cell的imageView的frame作为UIDragPreviewParameters的visiblePath
        dragPreviewParam.visiblePath = UIBezierPath.init(rect: (targetCell.videoPlayerLayer?.frame)!)
        return dragPreviewParam
    }
```
实现以上方法后，应该就可以发现预览图已经变了。

以上就是对于第一部分Drag 的实现

####Drop

第二部分就是将别的App的数据Drop到自己的App中。其实与第一部分大同小异，运用好NSItemProvider 就可以让你的数据传输在不同App之间畅通无阻。

####Step0 给UITableView 添加drop手势

实现tableView 的dropDelegate 即可：
主要是两个方法：
```
//告诉TabieView 能否handle某个dropSession
tableView(_:canHandle:)
//所要执行的drop动作
tableView(_:performDropWith:)
```
同时也建议实现
```
//告诉tableView该怎样处理这个dropSession（Copy or cancel or forbidden）
tableView(_:dropSessionDidUpdate:withDestinationIndexPath:)
```

####Step1 通过NSItemProvider 获取数据
当然其中最重要的还是通过NSItemProvider来获取到我们想要的数据。之前在Drag的部分我们已经介绍过如何注册文件和数据加载器。
与之相对的，NSItemProvider也有一系列方法来帮助我们获得已经注册过的数据：
```
loadItem(forTypeIdentifier:options:completionHandler:)
loadDataRepresentation(forTypeIdentifier:completionHandler:)
//加载一个文件（会将目标文件拷贝到一个临时的地方进行读取）
loadFileRepresentation(forTypeIdentifier:completionHandler:)
//加载一个文件（原地读取文件）
loadInPlaceFileRepresentation(forTypeIdentifier:completionHandler:)
loadObject(ofClass:completionHandler:)
```
会发现以上load方法与register方法基本上是一一对应的。应该比较好理解，Drag一方来注册，Drop一方来使用。

这里我们使用与前面对应的loadDataRepresentation 方法来进行加载：
```
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let dropItem = coordinator.items[0]
        let itemProvider = dropItem.dragItem.itemProvider
        itemProvider.loadDataRepresentation(forTypeIdentifier: itemProvider.registeredTypeIdentifiers.first!) { (data, error) in
            let tempPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).first
            var videoPath = NSString.init(string: tempPath!)
            videoPath = videoPath.appendingPathComponent("test.mp4") as NSString
            let videoData = data! as NSData
            let tempUrl = URL.init(fileURLWithPath: videoPath as String)
            //直接获取到视频文件data，然后写入到我们的文件中为后续的读取做准备
            videoData.write(to: tempUrl, atomically: true)
            let playerItem = AVPlayerItem.init(url: tempUrl)
            let player = AVPlayer.init(playerItem: playerItem)
            self.videoPlayers.append(player)
            self.videoPlayURLs.append(tempUrl as NSURL)
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
    }
```

=========================
demo地址：[https://github.com/madao1237/DragAndDropResearc](https://github.com/madao1237/DragAndDropResearch)
有问题共同交流学习，谢谢。







