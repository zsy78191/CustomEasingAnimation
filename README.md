# CustomEasingAnimation
A simple function to make bezier animation.
这一段代码，可以通用于三次贝塞尔缓动动画。

比如下段代码，将view平移了250px，并且动态改变label的文字。
```objc
[CustomEasingAnimation easingFrom:0 to:250 interval:1 timing:[CAMediaTimingFunction functionWithControlPoints:1 :0 :.5 :1.51] block:^(CGFloat value) {
        view.transform = CGAffineTransformMakeTranslation(value, 0);
        label.text = [NSString stringWithFormat:@"%.2f",value];
} comeplte:^{
       
}];
```

# 缓动动画 （Easing Animation）

缓动动画是目前iOS系统中非常常见的一类动画，大家一定不陌生。例如CocoaTouch框架中`CASpringAnimation`，是一种弹簧缓动动画，再比如`POP`框架的`POPSpringAnimation`，也是一种弹簧缓动动画，他们的效果如下：

![](https://segmentfault.com/img/bVstTb)

 当然`弹簧动画`是一种特殊的缓动动画，我们更常见的是根据bezier（贝赛尔）曲线构建的三次贝塞尔缓动动画。如果你不知道我在说啥，请看[Animations开源动效分析（二）POP-Stroke动画
](https://segmentfault.com/a/1190000004365988)
 
#bezier 曲线

bezier曲线我在大学中并没有接触过，估计学过计算机图学的朋友一定很熟悉，这里就不详细介绍了。简单说就是一条曲线，由起点、终点和两个控制点决定的一条曲线。在我们的缓动动画中，这条曲线决定了动画的效果。并且简化为起点在(0,0)，终点在(1,1)的一条曲线，所以这条曲线只由两个控制点决定。

这个曲线在Cocoa中对应的就是`CAMediaTimingFunction`类，下图是用一个开源软件生成的，软件地址是[keefo/CATweaker](https://github.com/keefo/CATweaker)。

![](https://segmentfault.com/img/bVstNN)

```objc
/* Creates a timing function modelled on a cubic Bezier curve. The end
 * points of the curve are at (0,0) and (1,1), the two points 'c1' and
 * 'c2' defined by the class instance are the control points. Thus the
 * points defining the Bezier curve are: '[(0,0), c1, c2, (1,1)]' */

+ (instancetype)functionWithControlPoints:(float)c1x :(float)c1y :(float)c2x :(float)c2y;

- (instancetype)initWithControlPoints:(float)c1x :(float)c1y :(float)c2x :(float)c2y;
```
 
传入的四个值，就是两个控制点的x，y坐标。范围是[0,1]。

#常见的Easing

常见的Easing有如下几种，你一定见过

* linear 直线
* easeIn 缓入
* easeOut 缓出
* easeInOut 缓出缓入

#bezier曲线填充

所谓的`填充`，就是通过bezier方程，根据x计算y的过程。比如在[0,1]区间内，取100个等距x值，对应计算y值，将这些点绘制再坐标轴上，x取得越多，整个点组成的曲线月平滑，却趋近于bezier曲线。

在我们做动画时，考虑到计时器（CADisplayLink）的刷新频率是60帧/秒，所以采样个数根据动画时长x频率决定。

首先来计算采样点，这段算法是我从wiki上搬过来的，数学渣伤不起。

头文件
```c
#ifndef bezier_h
#define bezier_h

#include <stdio.h>

/*
 產生三次方貝茲曲線的程式碼
 */

typedef struct
{
    float x;
    float y;
}
Point2D;
Point2D PointOnCubicBezier( Point2D* cp, float t );
void ComputeBezier( Point2D* cp, int numberOfPoints, Point2D* curve );

#endif /* bezier_h */
```

c文件
```c
#include "bezier.h"

/*
 cp在此是四個元素的陣列:
 cp[0]為起始點，或上圖中的P0
 cp[1]為第一個控制點，或上圖中的P1
 cp[2]為第二個控制點，或上圖中的P2
 cp[3]為結束點，或上圖中的P3
 t為參數值，0 <= t <= 1
 */

Point2D PointOnCubicBezier( Point2D* cp, float t )
{
    float   ax, bx, cx;
    float   ay, by, cy;
    float   tSquared, tCubed;
    Point2D result;
    
    /*計算多項式係數*/
    
    cx = 3.0 * (cp[1].x - cp[0].x);
    bx = 3.0 * (cp[2].x - cp[1].x) - cx;
    ax = cp[3].x - cp[0].x - cx - bx;
    
    cy = 3.0 * (cp[1].y - cp[0].y);
    by = 3.0 * (cp[2].y - cp[1].y) - cy;
    ay = cp[3].y - cp[0].y - cy - by;
    
    /*計算位於參數值t的曲線點*/
    
    tSquared = t * t;
    tCubed = tSquared * t;
    
    result.x = (ax * tCubed) + (bx * tSquared) + (cx * t) + cp[0].x;
    result.y = (ay * tCubed) + (by * tSquared) + (cy * t) + cp[0].y;
    
    return result;
}

/*
 ComputeBezier以控制點cp所產生的曲線點，填入Point2D結構的陣列。
 呼叫者必須分配足夠的記憶體以供輸出結果，其為<sizeof(Point2D) numberOfPoints>
 */

void ComputeBezier( Point2D* cp, int numberOfPoints, Point2D* curve )
{
    float   dt;
    int    i;
    dt = 1.0 / ( numberOfPoints - 1 );
    for( i = 0; i < numberOfPoints; i++)
        curve[i] = PointOnCubicBezier( cp, i*dt );
}
```
首先佩服数学好的大牛们，也感谢写代码的前辈们，我们通过上面这段代码来计算bezier采样点

```objc
+ (NSArray *)calculateFrameFromValue:(CGFloat)fromValue toValue:(CGFloat)toValue timing:(CAMediaTimingFunction *)function frameCount:(size_t)frameCount
{
    float p[4][2];
    Point2D cp[4];
    
    for (int i = 0; i < 4; ++i) {
        [function getControlPointAtIndex:i values:p[i]];
        //        NSLog(@"{%f,%f}",p[i][0],p[i][1]);
        cp[i].x = p[i][0];
        cp[i].y = p[i][1];
    }
    
    Point2D* curve = (Point2D*)malloc(frameCount * sizeof(Point2D));
    ComputeBezier(cp, (int)frameCount, curve);
    
    NSMutableArray* array = [NSMutableArray array];
    for (int i = 0; i < frameCount; ++i) {
        //        NSLog(@"{%f,%f}",curve[i].x,curve[i].y);
        [array addObject:@(curve[i].y * (toValue - fromValue) + fromValue)];
    }
    
    free(curve);
    
    return [array copy];
}
```
我们将`CAMediaTimingFunction`的两个控制点转成Point2D结构体，得到采样点的Y坐标数组，最后根据起点终点计算属性点，返回。

#动起来

获得位置数据以后，我们让他动起来

```objc
@interface CustomEasingAnimation()
{
    int _count;
    int _total;
}
@property (nonatomic, strong) CADisplayLink* link;
@property (nonatomic, strong) void (^ block)(CGFloat value);
@property (nonatomic, strong) void (^ finish) ();
@property (nonatomic, strong) NSArray* data;
@end
``` 

这里要用到就是`CADisplayLink`类，进行计时。

```objc
+ (void)easingFrom:(CGFloat)fromValue to:(CGFloat)toValue interval:(NSTimeInterval)interval timing:(CAMediaTimingFunction *)function block:(void (^)(CGFloat))block comeplte:(void (^)(void))finish
{
    CustomEasingAnimation* e = [[CustomEasingAnimation alloc] init];
    e.link = [CADisplayLink displayLinkWithTarget:e selector:@selector(tick:)];
    [e.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    e.block = block;
    e.data = [[self class] calculateFrameFromValue:fromValue toValue:toValue timing:function frameCount:interval * 60 / e.link.frameInterval];
    e.finish = finish;
}

- (void)setData:(NSArray *)data
{
    _data = data;
    _total = (int)data.count;
    _count = 0;
}

- (void)tick:(CADisplayLink*)sender
{
    if (_count < _total) {
        if (self.block) {
            self.block([self.data[_count] doubleValue]);
        }
        _count ++;
    }
    else
    {
        if (self.finish) {
            self.finish();
        }
        [sender invalidate];
    }
}
```
代码就不详尽解释了，没有什么难点（难的wiki拿来的代码都搞定了，那段代码我也看不懂，主要不懂bezier方程计算），有疑问可以留言。

其实整个功能，[POP](https://github.com/facebook/pop)和[Advance](https://github.com/storehouse/Advance)（一个新的swfit动画框架，非常屌）都有相关功能，但这两个框架比较比较重量级，所以如果只是需要用到一些简单功能可以选择我哦。	



