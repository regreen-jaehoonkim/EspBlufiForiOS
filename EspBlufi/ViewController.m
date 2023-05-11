//
//  ViewController.m
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/9.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ESPPeripheral.h"
#import "FFDropDownMenuView.h"
#import "MJRefresh.h"
#import "ESPSettingViewController.h"
#import "ESPDetailViewController.h"
#import "ESPFBYBLEHelper.h"
#import "ESPDataConversion.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) FFDropDownMenuView *dropDownMenu;
@property(nonatomic, strong) UITableView *peripheralView;
@property(nonatomic, copy)   NSMutableArray<ESPPeripheral *> *peripheralArray;
@property(nonatomic, strong) ESPFBYBLEHelper *espFBYBleHelper;
@property(nonatomic, strong) NSString *filterContent;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.espFBYBleHelper = [ESPFBYBLEHelper share];
    self.navigationItem.title = INTER_STR(@"EspBlufi-nav-title");
//    UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//    [menuBtn addTarget:self action:@selector(showDropDownMenu) forControlEvents:UIControlEventTouchUpInside];
//    [menuBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showDropDownMenu)];
    NSArray *modelsArray = [self getMenuModelsArray];
    self.dropDownMenu = [FFDropDownMenuView ff_DefaultStyleDropDownMenuWithMenuModelsArray:modelsArray menuWidth:140 eachItemHeight:50 menuRightMargin:FFDefaultFloat triangleRightMargin:FFDefaultFloat];
    [self setupBasedView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.filterContent = [ESPDataConversion loadBlufiScanFilter];
    [self scanDeviceInfo];
}

/**
ESPFBYBleHelper 객체를 사용하여 BLE 장치 검색을 시작하는 메소드입니다.
검색된 장치를 dataSource 배열(peripheralArray)에 추가하고, 메인 스레드에서 테이블 뷰나 컬렉션 뷰를 리로드합니다.
*/
- (void)scanDeviceInfo {
    NSLog(@"vc 扫描设备");
    
    // 이전 검색 결과를 제거하고 새로운 검색을 시작하기 전에 dataSource 배열(peripheralArray)을 초기화 합니다.
    [self.dataSource removeAllObjects];

    // ESPFBYBleHelper 객체를 사용하여 BLE 장치 검색을 시작합니다.
    [self.espFBYBleHelper startScan:^(ESPPeripheral * _Nonnull device) {

        // 검색된 디바이스를 dataSource 배열(peripheralArray)에 추가합니다.
        if ([self shouldAddToSource:device]) {
            [self.dataSource addObject:device];
            
            // 메인 스레드에서 테이블 뷰나 컬렉션 뷰를 리로드합니다.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.peripheralView reloadData];
            });
        }
    }];
}

- (NSArray *)getMenuModelsArray {
    __weak typeof(self) weakSelf = self;
    FFDropDownMenuModel *menuModel0 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:INTER_STR(@"EspBlufi-Setting") menuItemIconName:nil  menuBlock:^{
        ESPSettingViewController *svc = [ESPSettingViewController new];
        [weakSelf.navigationController pushViewController:svc animated:YES];
    }];
    NSArray *menuModelArr = @[menuModel0];
    return menuModelArr;
}

- (void)showDropDownMenu {
    [self.dropDownMenu showMenu];
}

- (void)setupBasedView {
    self.peripheralView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.peripheralView.delegate = self;
    self.peripheralView.dataSource = self;
    self.peripheralView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.peripheralView];
    self.peripheralView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(MJRefresh_header)];
}

- (void)MJRefresh_header{
    [self.peripheralView.mj_header beginRefreshing];
    [self scanDeviceInfo];
    sleep(3);
    [self.peripheralView.mj_header endRefreshing];
    [self.peripheralView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _peripheralArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (!ValidArray(_peripheralArray)) {
        return cell;
    }
    
    ESPPeripheral *device = _peripheralArray[indexPath.row];
    NSString *name = device.name;
    int rssi = device.rssi;
    NSString *uuid = device.uuid.UUIDString;
    
    UILabel *nameLab = [[UILabel alloc] init];
    nameLab.frame = CGRectMake(15, 0, CGRectGetWidth(tableView.frame), 40);
    NSString *deviceName = [NSString stringWithFormat:@"%@    %d", name, rssi];
    nameLab.text = deviceName;
    nameLab.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:nameLab];
    
    UILabel *uuidLab = [[UILabel alloc] init];
    uuidLab.frame = CGRectMake(15, 30,CGRectGetWidth(tableView.frame), 20);
    NSString *deviceInfo = [NSString stringWithFormat:@"%@",uuid];
    uuidLab.text = deviceInfo;
    uuidLab.textColor = [UIColor lightGrayColor];
    uuidLab.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:uuidLab];
    
    return cell;
}

// 테이블 뷰 셀 선택시 호출되는 메소드.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 셀 선택 해제 앤;메이션을 적용합니다.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // BLE 장치 배열이 유효하지 않으면 메소드를 종료합니다.
    if (!ValidArray(_peripheralArray)) {
        return;
    }

    // 선택된 셀에 해당하는 BLE 장치의 상세 정보를 표시하는 ESPDetailViewController 인스턴스를 생성합니다.
    ESPDetailViewController *dvc = [ESPDetailViewController new];

    // 선택된 셀에 해당하는 BLE 장치 객체를 설정합니다.
    dvc.device = _peripheralArray[indexPath.row];

    // EPSDetailViewController를 푸시하여 선택된 BLE 장치의 상세정보를 표시합니다.
    [self.navigationController pushViewController:dvc animated:YES];
}

// 검색된 BLE 장치를 저장하는 배열입니다.
- (NSMutableArray *)dataSource {
    // 배열이 nil인 경우, 새로운 NSMutableArray 인스턴스를 생성합니다.
    if (!_peripheralArray) {
        _peripheralArray = [[NSMutableArray alloc] init];
    }
    
    // 생성된 배열을 반환합니다.
    return _peripheralArray;
}

- (BOOL)shouldAddToSource:(ESPPeripheral *)device {
    NSArray *source = [self dataSource];
    // Check filter
    if (_filterContent && _filterContent.length > 0) {
        if (!device.name || ![device.name hasPrefix:_filterContent]) {
            // The device name has no filter prefix
            return NO;
        }
    }
    
    // Check exist
    for (int i = 0; i < source.count; i++) {
        ESPPeripheral *existDevice = source[i];
        if ([device.uuid isEqual:existDevice.uuid]) {
            // The device exists in source already
            return NO;
        }
    }
    
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.espFBYBleHelper stopScan];
}
@end
