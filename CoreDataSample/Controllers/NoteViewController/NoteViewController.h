//
//  ViewController.h
//  CoreDataSample
//
//  Created by Alina Hambaryan on 1/19/16.
//  Copyright © 2016 Alina Hambaryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Folder.h"

@interface NoteViewController : UIViewController

@property(nonatomic, strong) Folder *folder;

+(instancetype)createInstance;

@end

