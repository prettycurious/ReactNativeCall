//
//  RNTMapView.h
//  ReactNativeCall
//
//  Created by user on 2019/2/26.
//  Copyright © 2019 Facebook. All rights reserved.
//

// RNTMapView.h

#import <MapKit/MapKit.h>

#import <React/RCTComponent.h>

@interface RNTMapView: MKMapView

@property (nonatomic, copy) RCTBubblingEventBlock onRegionChange;

@end
