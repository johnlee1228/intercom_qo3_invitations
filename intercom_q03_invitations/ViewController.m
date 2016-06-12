//
//  ViewController.m
//  intercom_q03_invitations
//
//  Created by Kwok Lee on 12/6/16.
//  Copyright © 2016 John. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController

//#define kHQLatitudeDegree 53.3381985
//#define kHQLongitudeDegree -6.2592576

#define kHQLatitudeRad 0.930927180907301
#define kHQLongitudeRad -0.109244653850478

#define kEarthRadius 6371  //kilometers

//Keys of the JSON file
#define kLatitudeKey @"latitude"
#define kLongitudeKey @"longitude"
#define kUserIdKey @"user_id"
#define kUserNameKey @"name"



#pragma mark - VC life cycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *userList = [self getUserListWithFileName:@"gistfile1.txt" withinDistance:100];
    
    
    UITextView *textView = [[UITextView alloc]
                            initWithFrame:
                            CGRectMake(0.0f, 20.0f, //top indent 20
                                       self.view.bounds.size.width, self.view.bounds.size.height - 20.0f)];
    textView.text = [self displayStringFromUserList:userList];
    textView.editable = NO;
    
    
    [self.view addSubview:textView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Get Users Methods
- (NSArray *) getUserListWithFileName: (NSString *) fileName withinDistance: (double) distance{
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName
                                                     ofType:@""];
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];

    //raw users in string format
    NSArray *rawUserList = [content componentsSeparatedByString:@"\n"];
    
    //userList in NSDictionary format to be returned
    NSMutableArray *userList = [[NSMutableArray alloc]initWithCapacity:rawUserList.count];
    
    NSError *jsonError = nil;
    for (NSString *rawUser in rawUserList) {
        //Convert each rawUser strings into NSDictionary
        NSDictionary *user = [NSJSONSerialization
                              JSONObjectWithData:[rawUser dataUsingEncoding:NSUTF8StringEncoding]
                              options:kNilOptions
                              error:&jsonError];
        
        double latitude = [[user objectForKey:kLatitudeKey] doubleValue];
        double longitude = [[user objectForKey:kLongitudeKey]doubleValue];
       
        
        double userDistance = [self distanceFromHQAtLatitude:latitude andLongitude:longitude];
        
        if (userDistance <= distance){//Filtering for only Users near HQ
            int userId = [[user objectForKey:kUserIdKey] intValue];
            
            //Sorting with UserId in ascending order, worst case O(n^2), not sure if better to use block comparators
            BOOL addedInLoop = NO;
            for (int i = 0; i < userList.count; i++) {
                NSDictionary *currentUser = [userList objectAtIndex:i];
                int currentUserId = [[currentUser objectForKey:kUserIdKey] intValue];
                if (userId < currentUserId){
                    [userList insertObject:user atIndex:i];
                    addedInLoop = YES;
                    break;
                }
            }
            
            if (addedInLoop == NO)
                [userList addObject:user];
        }
    }
    
    
    return userList;
    
}

- (double) distanceFromHQAtLatitude: (double) latitudeDegree andLongitude: (double) longitudeDegree{
    //https://en.wikipedia.org/wiki/Great-circle_distance
    //First Equation -  spherical law of cosines
    
    double latitudeRad = [self degreeToRadians:latitudeDegree];
    double longitudeRad = [self degreeToRadians:longitudeDegree];
    
    
    double distance = kEarthRadius * acos(sin(kHQLatitudeRad)* sin(latitudeRad)
                           + cos(kHQLatitudeRad) * cos(latitudeRad) * cos(longitudeRad - kHQLongitudeRad));
    
    return distance;
}


- (double) degreeToRadians: (double) degree{
    return degree*(M_PI/180.0);
}


- (NSString *) displayStringFromUserList: (NSArray *) userList{
    NSString *displayString;
    if (userList.count > 0) displayString= @"Users within 100km:\n";
    else displayString = @"No user found within 100km";
    
    for (NSDictionary *user in userList) {
        displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@"User Id: %@  Name:%@\n", [user objectForKey:kUserIdKey], [user objectForKey:kUserNameKey]]];
    }
    return displayString;
    
}



@end






