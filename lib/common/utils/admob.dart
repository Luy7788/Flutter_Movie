import 'dart:io';
import 'dart:ui';

//import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nmtv/common/config/adapt.dart';
import 'package:nmtv/common/config/config.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:nmtv/common/utils/global.dart';

class admob {
//  bool _bannerHidden = false;
//  bool _intersitialHidden = false;
//  //横幅
//  BannerAd adBanner;
//  //插页
//  InterstitialAd adInterstitial;

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  AdmobInterstitial interstitialAd;

  OverlayEntry _overlay;

  admob() {
    init();
  }

  void init() {
    if (Config.isRelease == true) {}
    String ad_id = '';
    if (Config.isIOS == true) {
      ad_id = Config.ADMOB_APP_ID_iOS;
    } else {
      ad_id = Config.ADMOB_APP_ID_Android;
    }
    Admob.initialize(ad_id);

    print('-------------------admob 初始化initialize id: $ad_id');
    //弹窗广告
    interstitialAd = AdmobInterstitial(
      adUnitId: _InterstitialUnitID(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
        handleEvent(event, args, 'Interstitial');
      },
    );
//    interstitialAd.load();
  }

  OverlayEntry _createSelectViewWithContext(BuildContext context) {
    //屏幕宽高
    RenderBox renderBox = context.findRenderObject();
    var screenSize = renderBox.size;
    print('Global.config.enableAdnet ${Global.config.enableAdnet}');
    //正式创建Overlay
    return OverlayEntry(
        builder: (context) => Positioned(
              bottom: Adapt.padBotH() + kBottomNavigationBarHeight,
              width: screenSize.width,
              height: 60,
              child: AdmobBanner(
                adUnitId: _BannerUnitID(),
                adSize: AdmobBannerSize.BANNER,
                listener: (AdmobAdEvent event, Map<String, dynamic> args) {
                  handleEvent(event, args, 'Banner');
                },
              ),
            ));
  }

  //现实显示具体方法 在需要的地方掉用即可
  showBanner(BuildContext context, bool isShow) {
    if (isShow) {
      _overlay = _createSelectViewWithContext(context);
      Overlay.of(context).insert(_overlay);
    } else {
      _overlay.remove();
      _overlay = null;
    }
  }

  showInterstitialAd() {
    interstitialAd.show();
  }

  String _BannerUnitID() {
    String id;
    if (Config.isRelease == true) {
      if (Config.isIOS == true) {
        id = Config.ADMOB_Banner_UnitID_iOS;
      } else {
        id = Config.ADMOB_Banner_UnitID_Android;
      }
    } else {
      id = "ca-app-pub-3940256099942544/6300978111";
    }
    print('============admob============_BannerUnitID $id');
    return id;
  }

  String _InterstitialUnitID() {
    String id;
    if (Config.isRelease == true) {
      if (Config.isIOS == true) {
        id = Config.ADMOB_Interstitial_UnitID_iOS;
      } else {
        id = Config.ADMOB_Interstitial_UnitID_Android;
      }
    } else {
      id = "ca-app-pub-3940256099942544/1033173712";
//      return InterstitialAd.testAdUnitId;
    }
    print('============admob============_InterstitialUnitID $id');
    return id;
  }

  void handleEvent(
      AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
        showSnackBar('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
        showSnackBar('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        showSnackBar('Admob $adType Ad closed!');
        break;
      case AdmobAdEvent.failedToLoad:
        print('=============Admob\n $args,\n $adType');
        showSnackBar('Admob $adType failed to load. :(');
        break;
      case AdmobAdEvent.rewarded:
        showDialog(
          context: scaffoldState.currentContext,
          builder: (BuildContext context) {
            return WillPopScope(
              child: AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Reward callback fired. Thanks Andrew!'),
                    Text('Type: ${args['type']}'),
                    Text('Amount: ${args['amount']}'),
                  ],
                ),
              ),
              onWillPop: () async {
                scaffoldState.currentState.hideCurrentSnackBar();
                return true;
              },
            );
          },
        );
        break;
      default:
    }
  }

  void showSnackBar(String content) {
    scaffoldState.currentState.showSnackBar(SnackBar(
      content: Text(content),
      duration: Duration(milliseconds: 1500),
    ));
  }

//  void _MobileAdListener(MobileAdEvent event) async {
//    print('1-------------------MobileAdEvent: $event');
//    if (event == MobileAdEvent.loaded) {
//      if (this._bannerHidden == true && this.adBanner != null) {
//        hideAdBanner();
//      }
//    } else if (event == MobileAdEvent.failedToLoad) {
//      if (this._bannerHidden == true && this.adBanner != null) {
//        hideAdBanner();
//      }
//    }
//  }
//
//  void showAdBanner({VoidCallback onLoaded, VoidCallback onError}) {
//    print('2-------------------showAdBanner');
//    if (this.adBanner != null) {
//      return;
//    }
//    this._bannerHidden = false;
//    this.adBanner = BannerAd(
//        adUnitId: _BannerUnitID(),
//        size: AdSize.smartBanner,
//        targetingInfo: targetingInfo,
//        listener: (MobileAdEvent event) async {
//          print('1-------------------showAdBanner: $event');
//          switch (event) {
//            case MobileAdEvent.loaded:
//              if (this._bannerHidden == true && this.adBanner != null) {
//                hideAdBanner();
//              }
//              if (onLoaded != null) {
//                onLoaded();
//              }
//              break;
//            case MobileAdEvent.failedToLoad:
//              if (this._bannerHidden == true && this.adBanner != null) {
//                hideAdBanner();
//              }
//              if (onError != null) {
//                onError();
//              }
//              break;
//          }
//        });
//    this.adBanner
//      ..load()
//      ..show(
//        anchorOffset: kBottomNavigationBarHeight, //垂直方向偏移
//        horizontalCenterOffset: 0.0, //水平方向偏移
//        anchorType: AnchorType.bottom,
//      );
//    ;
//  }
//
//  void hideAdBanner() {
//    this._bannerHidden = true;
//    print('3-------------------dispose');
//    Future.delayed(const Duration(milliseconds: 400), () {
//      this._bannerHidden = true;
//      this.adBanner?.dispose();
//      this.adBanner = null;
//    });
//  }
//
//  void showAdInterstitial() {
//    if (adInterstitial != null) {
//      return;
//    }
//    _intersitialHidden = false;
//    adInterstitial = InterstitialAd(
//        adUnitId: _InterstitialUnitID(),
//        targetingInfo: targetingInfo,
//        listener: (MobileAdEvent event) async {
//          if (event == MobileAdEvent.loaded) {
//            if (_intersitialHidden) {
//              hideAdInterstitial();
//            }
//          } else if (event == MobileAdEvent.failedToLoad) {
//            if (_intersitialHidden) {
//              hideAdInterstitial();
//            }
//          }
//        });
//    adInterstitial
//      ..load()
//      ..show(
//        anchorType: AnchorType.bottom,
//        anchorOffset: 0.0,
//        horizontalCenterOffset: 0.0,
//      );
//    print('1-------------------hideAdInterstitial: ${this.adInterstitial}');
//  }
//
//  void hideAdInterstitial() {
//    print('2-------------------hideAdInterstitial: ${this.adInterstitial}');
//    Future.delayed(Duration(milliseconds: 100), () {
//      _intersitialHidden = true;
//      adInterstitial?.dispose();
//      adInterstitial = null;
//    });
//  }
}

//
//MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//  keywords: <String>['flutterio', 'beautiful apps'],
//  contentUrl: 'https://flutter.io',
//  birthday: DateTime.now(),
//  childDirected: false,
//  designedForFamilies: false,
//  gender: MobileAdGender.unknown,
//  // or MobileAdGender.female, MobileAdGender.unknown
//  testDevices: <String>[], // Android emulators are considered test devices
//);
