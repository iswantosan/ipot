// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'IPOT Order';

  @override
  String get scanTitle => '扫码点单';

  @override
  String get scanHint => '将相机对准桌上的二维码';

  @override
  String get scanInvalid => '无法识别二维码 — 请确认这是 IPOT 桌台二维码';

  @override
  String get scanManualEntry => '手动输入桌号';

  @override
  String get scanEnterTableId => '输入桌号';

  @override
  String get scanTableHint => '例如 T001';

  @override
  String get scanCameraUnavailable => '相机不可用';

  @override
  String get scanTagline => '几秒钟,从你的桌台下单';

  @override
  String get permissionCameraTitle => '需要相机权限';

  @override
  String get permissionCameraBody => '我们使用相机扫描你桌上的二维码。摄像数据仅在本设备上处理。';

  @override
  String get permissionAllow => '允许使用相机';

  @override
  String get permissionNotNow => '暂不';

  @override
  String get permissionDeniedTitle => '相机权限已被拒绝';

  @override
  String get permissionDeniedBody => '你可以在系统设置中授予相机权限,或手动输入桌号。';

  @override
  String get permissionOpenSettings => '打开设置';

  @override
  String get actionCancel => '取消';

  @override
  String get actionOpenMenu => '打开菜单';

  @override
  String get actionRetry => '重试';

  @override
  String get actionAddToCart => '加入购物车';

  @override
  String get actionPlaceOrder => '下单';

  @override
  String get actionClear => '清空';

  @override
  String get actionBackToMenu => '返回菜单';

  @override
  String menuTable(String id) {
    return '桌号 $id';
  }

  @override
  String get menuFailedLoad => '菜单加载失败';

  @override
  String get menuSearchHint => '搜索菜单...';

  @override
  String get menuEmptyCategory => '此分类暂无菜品';

  @override
  String get menuNoMatches => '无匹配结果';

  @override
  String get itemNotes => '备注';

  @override
  String get itemNotesHint => '例如:微辣、不要洋葱';

  @override
  String get itemQuantity => '数量';

  @override
  String get itemRequired => '必选';

  @override
  String itemMaxSelections(int n) {
    return '最多 $n 项';
  }

  @override
  String get itemFree => '免费';

  @override
  String get itemPickRequired => '请先选择必选项';

  @override
  String get cartTitle => '购物车';

  @override
  String get cartClearTitle => '清空购物车?';

  @override
  String get cartClearBody => '将从购物车中移除所有商品。';

  @override
  String get cartNoteHint => '给厨房的备注(选填)';

  @override
  String cartSubtotal(int count) {
    return '小计($count 件)';
  }

  @override
  String get cartEmpty => '购物车为空';

  @override
  String get cartEmptyHint => '从菜单添加一些菜品吧';

  @override
  String cartLineNote(String note) {
    return '备注:$note';
  }

  @override
  String get orderSubmitting => '正在提交订单...';

  @override
  String get orderSubmitFailed => '下单失败';

  @override
  String get orderConfirmedTitle => '下单成功!';

  @override
  String orderConfirmedSubtitle(String id) {
    return '订单号 #$id';
  }

  @override
  String get orderTrackTitle => '订单跟踪';

  @override
  String get orderStatusPending => '待处理';

  @override
  String get orderStatusConfirmed => '已确认';

  @override
  String get orderStatusPreparing => '制作中';

  @override
  String get orderStatusReady => '可取餐';

  @override
  String get orderStatusServed => '已送达';

  @override
  String orderEta(int minutes) {
    return '约 $minutes 分钟后准备完成';
  }

  @override
  String get orderBackToScan => '返回扫码';
}
