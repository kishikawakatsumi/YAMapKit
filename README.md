YAMapKit
========

Yet Another MapKit.framework based on Google Maps Javascript API.  
Inspired by [MacMapKit](https://github.com/Oomph/MacMapKit).

------
<img src="https://github.com/downloads/kishikawakatsumi/YAMapKit/1.png" alt="ScreenShot1" width="225px" style="width: 225px;" />&nbsp;
<img src="https://github.com/downloads/kishikawakatsumi/YAMapKit/2.png" alt="ScreenShot2" width="225px" style="width: 225px;" />&nbsp;
<img src="https://github.com/downloads/kishikawakatsumi/YAMapKit/3.png" alt="ScreenShot3" width="225px" style="width: 225px;" />&nbsp;
<img src="https://github.com/downloads/kishikawakatsumi/YAMapKit/4.png" alt="ScreenShot4" width="225px" style="width: 225px;" />&nbsp;
<img src="https://github.com/downloads/kishikawakatsumi/YAMapKit/5.png" alt="ScreenShot5" width="225px" style="width: 225px;" />&nbsp;


It Works
--------
YAMapKit implements nearly 100% of MK* functionality. It's been tested on iOS 5 and 6.
  
   
**Unsupported Features**  
* Geocoding. (Use 'CLGeocoder' instead.)
* Custom overlay views. (Supported builtin classes only. e.g. MKPolylineView, MKCircleView and so on.)

What's Provided
---------------
There's currently a framework and a small demo application.

Documentation
---------------
Because the framework is API compatible with Apple's, you can use [their documentation](http://developer.apple.com/library/ios/#documentation/MapKit/Reference/MapKit_Framework_Reference/_index.html) as a reference.


## Usage
1. Unlink Apple's MapKit.framework.
2. Link libMapKit.a
3. Link CoreLocation.framework

<img src="https://github.com/downloads/kishikawakatsumi/YAMapKit/build_settings1.png" alt="Build Settings" width="800px" style="width: 800px;" />

## 3rd party libraries

**MacMapKit**  
[https://github.com/Oomph/MacMapKit](https://github.com/Oomph/MacMapKit) 
MacMapKit is distributed under the [BSD license][BSD]. However, MacMapKit uses Google services to provide map data. Use of specific classes of this framework (and their associated interfaces) binds you to the Google Maps/Google Earth API terms of service. You can find these terms of service at [http://code.google.com/apis/maps/terms.html](http://code.google.com/apis/maps/terms.html).  
 
[Apache]: http://www.apache.org/licenses/LICENSE-2.0
[MIT]: http://www.opensource.org/licenses/mit-license.php
[GPL]: http://www.gnu.org/licenses/gpl.html
[BSD]: http://opensource.org/licenses/bsd-license.php

## License

YAMapKit is available under the [MIT license][MIT]. See the LICENSE file for more info.