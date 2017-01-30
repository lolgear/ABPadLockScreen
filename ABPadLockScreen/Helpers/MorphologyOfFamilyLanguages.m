//
//  MorphologyOfFamilyLanguages.m
//
//  Created by Lobanov Dmitry on 27.12.12.
//
//

#import "MorphologyOfFamilyLanguages.h"

typedef NS_ENUM(NSInteger, FamilyLanguages){
    FamilyLanguagesNone = 0,
    FamilyLanguagesEnglish,
    FamilyLanguagesRussian,
    FamilyLanguagesEnumCount
};

static inline NSString* stringFamilyLanguages(FamilyLanguages object){
    NSString* stringResult = nil;
    switch (object) {
        case FamilyLanguagesEnglish:
            stringResult = @"en,es";
            break;
        case FamilyLanguagesRussian:
            stringResult = @"ru";
            break;
        default:
            break;
    }
    return stringResult;
}
@interface MorphologyOfFamilyLanguages()

@property (nonatomic)NSUInteger cycleInCount;
@property (nonatomic)FamilyLanguages currentFamilyLanguage;

/*-----------protected methods-------------*/
-(FamilyLanguages)familyLanguagesObjectFromString:(NSString*)object;
-(NSUInteger)cycleInCountForCurrentLanguage;
-(BOOL)languageRuleSingle:(NSUInteger)count;
-(BOOL)languageRuleFew:(NSUInteger)count;
-(BOOL)languageRuleMany:(NSUInteger)count;
@end

/*------------prefixes-----------------*/
static const NSString* numeralAsSingle = @"single";
static const NSString* numeralAsFew    = @"few";
static const NSString* numeralAsMany   = @"many";


@implementation MorphologyOfFamilyLanguages
@synthesize currentLanguageSetting = _currentLanguageSetting;
@synthesize currentFamilyLanguage =  _currentFamilyLanguage;
@synthesize cycleInCount = _cycleInCount;
-(NSString*)currentLanguageSetting{
    if (_currentLanguageSetting == nil){
        //take? hm..
        return _currentLanguageSetting;
    }
    return _currentLanguageSetting;
}
-(void)setCurrentLanguageSetting:(NSString *)currentLanguageSetting{

    if(self.currentLanguageSetting == currentLanguageSetting){return;}
    if(currentLanguageSetting == nil){
        //clear setting
        _currentLanguageSetting = nil;
        _currentFamilyLanguage = FamilyLanguagesNone;
        _cycleInCount = 0;
    }
    if(currentLanguageSetting != nil){
        //set new setting
        _currentLanguageSetting = currentLanguageSetting;
        _currentFamilyLanguage  = [self familyLanguagesObjectFromString:currentLanguageSetting];
        _cycleInCount           = [self cycleInCountForCurrentLanguage];
    }
}

/*-----------protected methods-------------*/
-(FamilyLanguages)familyLanguagesObjectFromString:(NSString *)object{
    FamilyLanguages currentFamily = FamilyLanguagesNone;
    for (FamilyLanguages i = FamilyLanguagesNone; i<FamilyLanguagesEnumCount;++i){
        if([stringFamilyLanguages(i) rangeOfString:object].location != NSNotFound){
            currentFamily = i;
        }
    }
    return currentFamily;
}
-(NSUInteger)cycleInCountForCurrentLanguage{
    NSUInteger integerResult = 0;
    switch (_currentFamilyLanguage) {
        case FamilyLanguagesEnglish:
            integerResult = 0; //no needed cycle
            break;
        case FamilyLanguagesRussian:
            integerResult = 100; //yes, we have a cycle 100. it means, that we have "iteration(<>%<>)" every 100 years ;)
            break;
        default:
            break;
    }
    return integerResult;
}
-(BOOL)languageRuleSingle:(NSUInteger)count{
    BOOL boolResult = NO;
    if (_cycleInCount) {
        count%=_cycleInCount;
    }
    switch (_currentFamilyLanguage) {
        case FamilyLanguagesEnglish: {
            boolResult = (count==1);
            break;
        }
        case FamilyLanguagesRussian: {
            boolResult = (count%10==1)&&(count>20||count<10);
            break;
        }
        default: break;
    }
    return boolResult;
}
-(BOOL)languageRuleFew:(NSUInteger)count{
    BOOL boolResult = NO;
    if (_cycleInCount) {
        count%=_cycleInCount;
    }
    switch (_currentFamilyLanguage) {
        case FamilyLanguagesEnglish: {
            boolResult = NO; //not needed
            break;
        }
        case FamilyLanguagesRussian: {
            boolResult = ((count<=10) || (count>=20)) && (count%10>=2) && (count%10<=4);
            break;
        }
        default: break;
    }
    return boolResult;
}
-(BOOL)languageRuleMany:(NSUInteger)count{
    BOOL boolResult = NO;
    
    if(_cycleInCount){
        count%=_cycleInCount;
    }
    
    switch (_currentFamilyLanguage) {
        case FamilyLanguagesEnglish: {
            boolResult = (count!=1);
            break;
        }
        case FamilyLanguagesRussian: {
            boolResult = ((count>=10)&&(count<=20))||(count%10>=5)||(count%10==0);
            break;
        }
        default: break;
    }
    return boolResult;
}

/*-----------public methods----------------*/

/*-----------initialization----------------*/
-(instancetype)initWithLanguageSetting:(NSString*)languageSetting{
    self = [super init];
    if(self){
        [self setCurrentLanguageSetting:languageSetting];
        
    }
    return self;
}
+(instancetype)createWithLanguageSetting:(NSString*)languageSetting{
    MorphologyOfFamilyLanguages*object = nil;
    object = [[MorphologyOfFamilyLanguages alloc] initWithLanguageSetting:languageSetting];
    return object;
}

/*----------------main---------------------*/
-(NSString*)stringNumeralKeyFromCount:(NSUInteger)count{
    const NSString* stringResult = nil;
    BOOL ifSingle = [self languageRuleSingle:count];
    BOOL ifFew = [self languageRuleFew:count];
    BOOL ifMany = [self languageRuleMany:count];
    stringResult = (ifSingle?numeralAsSingle:(ifFew?numeralAsFew:(ifMany?numeralAsMany:@"")));
    return [stringResult copy];
}

-(NSString*)chooseStringCount:(NSUInteger)count betweenMany:(NSString*)many orFew:(NSString*)few orSingle:(NSString*)single {
    NSString* stringResult = nil;
    BOOL ifSingle = [self languageRuleSingle:count];
    BOOL ifFew = [self languageRuleFew:count];
    BOOL ifMany = [self languageRuleMany:count];

    stringResult =
    ifSingle ?
      single
    :
    ifFew ?
      few
    :
    ifMany ?
      many
    :
      nil;
    return [stringResult copy];
}


@end
