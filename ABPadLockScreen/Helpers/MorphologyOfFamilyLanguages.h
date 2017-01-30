//
//  MorphologyOfFamilyLanguages.h
//
//  Created by Lobanov Dmitry on 27.12.12.
//
//

#import <Foundation/Foundation.h>

@interface MorphologyOfFamilyLanguages : NSObject
/*
 @abstract
 this class is needed for rules and numerals in family languages.
 
 many languages have different rules of countable items, but in one family rules are the same
 */
/*
 @properties
 
 currentLanguageSetting
 */
/*
 @meaning
 this property is needed for current language setting on device.
 */
@property (nonatomic,strong)NSString* currentLanguageSetting;


/*
 @methods
 stringNumeralKeyFromCount
 */
/*
 @meaning
 this method create new object of this class with specific language setting
 */
+(instancetype)createWithLanguageSetting:(NSString*)languageSetting;
/*
 @meaning
 this method is needed for prefix
 */
-(NSString*)stringNumeralKeyFromCount:(NSUInteger)count;

/*
 @meaning
 this method is needed for choosing between single, few or manu count of string
 */
-(NSString*)chooseStringCount:(NSUInteger)count betweenMany:(NSString*)many orFew:(NSString*)few orSingle:(NSString*)single;
@end
