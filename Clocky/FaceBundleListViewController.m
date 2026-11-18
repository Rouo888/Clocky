//
//  FaceBundleListViewController.m
//  Clocky
//
//  Created by Jinwoo Kim on 11/18/26.
//

#import "FaceBundleListViewController.h"
#include <assert.h>

@interface FaceBundleListViewController ()
@property (nullable, nonatomic, copy, direct) NSArray<__kindof NTKFaceBundle *> *faceBundles;
@property (nullable, nonatomic, retain, direct) UICollectionViewCellRegistration *cellRegistration;
@end

@implementation FaceBundleListViewController

- (void)dealloc {
    [_faceBundles release];
    [_cellRegistration release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CLKDevice *device = CLKDevice.currentDevice;
    NSMutableArray<__kindof NTKFaceBundle *> *faceBundles = [[NSMutableArray alloc] init];
    [NTKFaceBundleManager.sharedManager enumerateFaceBundlesOnDevice:device includingLegacy:YES withBlock:^(__kindof NTKFaceBundle *faceBundle) {
        [faceBundles addObject:faceBundle];
    }];
    self.faceBundles = faceBundles;
    [faceBundles release];
    
    UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:[PUICListPlatterCell class] configurationHandler:^(__kindof UICollectionViewCell *cell, NSIndexPath *indexPath, __kindof NTKFaceBundle *faceBundle) {
        UIListContentConfiguration *contentConfiguration = [UIListContentConfiguration _defaultInsetGroupedCellConfiguration];
        NSString * _Nullable title = [faceBundle galleryTitleForDevice:device];
        if (title == nil) {
            title = [[faceBundle class] identifier];
        }
        if (title == nil) {
            title = NSStringFromClass([faceBundle class]);
        }
        contentConfiguration.text = title;
        cell.contentConfiguration = contentConfiguration;
    }];
    self.cellRegistration = cellRegistration;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.faceBundles.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCellRegistration *cellRegistration = self.cellRegistration;
    NSArray<__kindof NTKFaceBundle *> *faceBundles = self.faceBundles;
    assert(cellRegistration != nil && faceBundles != nil);
    return [collectionView dequeueConfiguredReusableCellWithRegistration:cellRegistration forIndexPath:indexPath item:faceBundles[indexPath.item]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<__kindof NTKFaceBundle *> *faceBundles = self.faceBundles;
    assert(faceBundles != nil);
    __kindof NTKFaceBundle *faceBundle = faceBundles[indexPath.item];
    id<FaceBundleListViewControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(faceBundleListViewController:didSelectFaceBundle:)]) {
        [delegate faceBundleListViewController:self didSelectFaceBundle:faceBundle];
    }
}

@end
