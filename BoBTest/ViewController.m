//
//  ViewController.m
//  BoBTest
//
//  Created by 曹洁 on 16/5/16.
//  Copyright © 2016年 曹洁. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSMutableArray *dataArr;
    float m_w,m_h;
    UITextField *nameF;
    UITextField *urlF;
    UIView *back;
    UITableView *table;
    NSMutableArray *ids;
    NSString *cookie;
    AFHTTPRequestOperationManager *manager;
    NSString *htmlkey;
}

-(void)getkey
{
    [SVProgressHUD showWithStatus:@"获取key中，请耐心等候"];
//    NSString *htmlString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://xzfuli.cn/index.php"] encoding:NSUTF8StringEncoding error:nil];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/html", nil]];
    [manager GET:@"http://xzfuli.cn/index.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *htmlString= [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSRange key = [htmlString rangeOfString:@"'key'"];
        htmlString = [htmlString substringFromIndex:key.location];
        [htmlString substringToIndex:50];
        NSArray *strarr = [htmlString componentsSeparatedByString:@"'"];
        htmlkey = [strarr objectAtIndex:3];
        
        [SVProgressHUD dismiss];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"获取失败"];
    }];
    

    
}

-(void)loadData
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *urls = [defaults objectForKey:@"urls"];//根据键值取出name
    
    NSArray *urlArr = [urls componentsSeparatedByString:@","];
    
    NSString *names = [defaults objectForKey:@"names"];//根据键值取出name
    
    NSArray *nameArr = [names componentsSeparatedByString:@","];
    
    dataArr = [[NSMutableArray alloc]init];
    if([urls length]>0)
    {
        for(int i=0;i<[urlArr count];i++)
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:[urlArr objectAtIndex:i] forKey:@"url"];
            [dic setObject:[nameArr objectAtIndex:i] forKey:@"name"];
            [dic setObject:@"0" forKey:@"status"];
            [dataArr addObject:dic];
        }
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    m_w = [UIScreen mainScreen].bounds.size.width;
    m_h = [UIScreen mainScreen].bounds.size.height;
    
    manager = [AFHTTPRequestOperationManager manager];
    [self getkey];
    [self loadData];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, m_w, m_h)];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    
    
    back = [[UIView alloc]initWithFrame:CGRectMake(0, 0, m_w, m_h)];
    [back setBackgroundColor:[UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:0.8]];

    
    UIView *form = [[UIView alloc]initWithFrame:CGRectMake(m_w/2-100, m_h/2-100, 200, 200)];
    [form setBackgroundColor:[UIColor whiteColor]];
    form.layer.cornerRadius = 10.0;
    [back addSubview:form];
    
    UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 50, 30)];
    l.text = @"备注:";
    [l setTextColor:[UIColor blackColor]];
    [form addSubview:l];
    
    nameF = [[UITextField alloc]initWithFrame:CGRectMake(60, 10, 130, 30)];
    [form addSubview:nameF];
    
    UILabel *urll = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 50, 30)];
    urll.text = @"url:";
    [urll setTextColor:[UIColor blackColor]];
    [form addSubview:urll];
    
    urlF = [[UITextField alloc]initWithFrame:CGRectMake(60, 50, 130, 30)];
    [form addSubview:urlF];
    
    
    UIButton *qx = [[UIButton alloc]initWithFrame:CGRectMake(10, 100, (200-30)/2, 30)];
    qx.tag = 0;
    [qx setTitle:@"取消" forState:UIControlStateNormal];
    [qx setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    qx.layer.cornerRadius = 8.0;
    [qx setBackgroundColor:[UIColor grayColor]];
    
    UIButton *qd = [[UIButton alloc]initWithFrame:CGRectMake(10+(200-30)/2+10, 100, (200-30)/2, 30)];
    qd.tag = 1;
    [qd setTitle:@"确定" forState:UIControlStateNormal];
    [qd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    qd.layer.cornerRadius = 8.0;
    [qd setBackgroundColor:[UIColor blueColor]];
    
    [qx addTarget:self action:@selector(btClick:) forControlEvents:UIControlEventTouchUpInside];
    [qd addTarget:self action:@selector(btClick:) forControlEvents:UIControlEventTouchUpInside];

    [form addSubview:qx];
    [form addSubview:qd];
    
    back.hidden = YES;
    
    [self.view addSubview:back];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rbtClick:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"执行" style:UIBarButtonItemStyleDone target:self action:@selector(lbtClick:)];
    
    self.navigationItem.title = @"批量刷棒棒糖";
    
    UIWebView *webv = [[UIWebView alloc]init];
    [webv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://xzfuli.cn/index.php"]]];
    [self.view addSubview:webv];
}
-(void)rbtClick:(UIButton *)sender
{
    back.hidden = NO;
}

-(void)getCookie
{
    NSString *domainStr = @"http://xzfuli.cn/index.php";
    
    //假如需要提交给服务器的参数是key＝1,class_id=100
    //创建一个可变字典
    NSMutableDictionary *parametersDic = [NSMutableDictionary dictionary];
    
    
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",@"text/html", @"text/plain",@"text/json",nil]];
    
    [manager.requestSerializer setTimeoutInterval:60];//请求超时时间20s
    
    manager.requestSerializer= [AFHTTPRequestSerializer serializer];
    manager.responseSerializer= [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:@"application/json, text/javascript, */*; q=0.01" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"xzfuli.cn" forHTTPHeaderField:@"Host"];
    [manager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 9_3_2 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13F69" forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:@"application/json, text/javascript, */*; q=0.01" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"zh-CN" forHTTPHeaderField:@"Accept-Language"];
    [manager.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [manager.requestSerializer setValue:@"http://xzfuli.cn/" forHTTPHeaderField:@"Referer"];
    [manager.requestSerializer setValue:@"39" forHTTPHeaderField:@"Content-Length"];
    
    cookie = [NSString stringWithFormat:@"Hm_lpvt_0b26b38275bd2d39888e8e2f5075886b=1465184212; Hm_lvt_0b26b38275bd2d39888e8e2f5075886b=1465183650,1465183783,1465183912,1465184212; CNZZDATA1256259678=1073903203-1465179790-http://xzfuli.cn/1465179790; PHPSESSID=cq1d3f6s822piargbu74orukg5; cy-third-cookie=used; tgw_l7_route=3ea9d48c1ba4c222f6bdff6405096fc7"];
    
    [manager.requestSerializer setValue:cookie forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    
    [manager GET:domainStr parameters:parametersDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 隐藏系统风火轮
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 解析失败隐藏系统风火轮(可以打印error.userInfo查看错误信息)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"%@",error.userInfo);
        [SVProgressHUD showErrorWithStatus:@"请求失败"];
    }];
    
}

-(void)lbtClick:(UIButton *)sender
{
    ids = [[NSMutableArray alloc]init];
    [self getCookie];
    
    //服务器给的域名
    NSString *domainStr = @"http://xzfuli.cn/index.php?a=api_qiuqiu";
    
    //假如需要提交给服务器的参数是key＝1,class_id=100
    //创建一个可变字典
    NSMutableDictionary *parametersDic = [NSMutableDictionary dictionary];
    
    if([dataArr count]>0)
    {
        // 启动系统风火轮
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [SVProgressHUD showWithStatus:@"获取数据中"];
        NSMutableDictionary *count = [[NSMutableDictionary alloc]init];
        [count setObject:[NSString stringWithFormat:@"%d",0] forKey:@"count"];
        
        for(int i=0;i<[dataArr count];i++)
        {
            [parametersDic removeAllObjects];
            //往字典里面添加需要提交的参数
            NSString *headStr = [[[dataArr objectAtIndex:i] objectForKey:@"url"] substringToIndex:8];
            if([headStr isEqualToString:@"http://d"])
            {
                [parametersDic setObject:@"1" forKey:@"type"];
            }else if([headStr isEqualToString:@"http://t"])
            {
                [parametersDic setObject:@"4" forKey:@"type"];
            }else{
                continue;
            }
            [parametersDic setObject:[[dataArr objectAtIndex:i] objectForKey:@"url"] forKey:@"url"];
            
            
            //以post的形式提交，POST的参数就是上面的域名，parameters的参数是一个字典类型，将上面的字典作为它的参数
            [manager POST:domainStr parameters:parametersDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                // 隐藏系统风火轮
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                //json解析
                NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                
                if([[resultDic objectForKey:@"code"] intValue]==0)
                {
                    NSArray *urlArr = [[resultDic objectForKey:@"url"] componentsSeparatedByString:@"="];
                    
                    
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                    [dic setObject:[NSString stringWithFormat:@"%d",i] forKey:@"index"];
                    [dic setObject:[[[urlArr objectAtIndex:1] componentsSeparatedByString:@"&"] objectAtIndex:0] forKey:@"id"];
                    
                    [ids addObject:dic];
                    
                }
                
                int coun = [[count objectForKey:@"count"] intValue];
                [count setObject:[NSString stringWithFormat:@"%d",++coun] forKey:@"count"];
                if(coun == [dataArr count])
                {
                    [self dosubmit];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                // 解析失败隐藏系统风火轮(可以打印error.userInfo查看错误信息)
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                NSLog(@"%@",error.userInfo);
                [SVProgressHUD showErrorWithStatus:@"获取失败"];
            }];
            
        }
        
    }else{
        [SVProgressHUD showErrorWithStatus:@"请添加数据"];
    }
    
    
    
    
    
}

-(void)dosubmit
{
    
    [SVProgressHUD dismiss];
    [SVProgressHUD showWithStatus:@"执行中"];
    
    NSString *domainStr = @"http://xzfuli.cn/index.php?a=api_qiuqiu";
    
    NSMutableDictionary *count = [[NSMutableDictionary alloc]init];
    [count setObject:[NSString stringWithFormat:@"%d",0] forKey:@"count"];
    NSMutableDictionary *parametersDic = [NSMutableDictionary dictionary];

    for(int i=0;i<[ids count];i++)
    {
        //往字典里面添加需要提交的参数
        [parametersDic removeAllObjects];
        [parametersDic setObject:@"2" forKey:@"type"];
        [parametersDic setObject:[[ids objectAtIndex:i] objectForKey:@"id"] forKey:@"id"];
        [parametersDic setObject:htmlkey forKey:@"key"];
        
        [manager POST:domainStr parameters:parametersDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // 隐藏系统风火轮
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            //json解析
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            
            if([[resultDic objectForKey:@"code"] intValue]==0)
            {
                [[dataArr objectAtIndex:[[[ids objectAtIndex:i] objectForKey:@"index"] intValue]] setObject:@"1" forKey:@"status"];
                [table reloadData];
                int coun = [[count objectForKey:@"count"] intValue];
                [count setObject:[NSString stringWithFormat:@"%d",++coun] forKey:@"count"];
                if(coun == [ids count])
                {
//                    [SVProgressHUD dismiss];
                    [SVProgressHUD showSuccessWithStatus:@"执行成功"];
                }
            }else{
//                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:[resultDic objectForKey:@"msg"]];

            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // 解析失败隐藏系统风火轮(可以打印error.userInfo查看错误信息)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
        }];
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSMutableArray *names = [[NSMutableArray alloc]init];
    NSMutableArray *urls = [[NSMutableArray alloc]init];
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [dataArr removeObjectAtIndex:indexPath.row];
        for(int i=0;i<[dataArr count];i++)
        {
            [names addObject:[[dataArr objectAtIndex:i] objectForKey:@"name"]];
            [urls addObject:[[dataArr objectAtIndex:i] objectForKey:@"url"]];
        }
        if([urls count]>0)
        {
            NSString *nameStr = [names componentsJoinedByString:@","];
            NSString *urlStr = [urls componentsJoinedByString:@","];
            
            
            [defaults setObject:urlStr forKey:@"urls"];
            [defaults setObject:nameStr forKey:@"names"];
            
        }else{
            [defaults setObject:@"" forKey:@"urls"];
            [defaults setObject:@"" forKey:@"names"];
        }
        [SVProgressHUD showSuccessWithStatus:@"删除成功"];
        [table reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


-(void)btClick:(UIButton *)sender
{
    if(sender.tag==0)
    {
        back.hidden = YES;
    }else if(sender.tag==1){
        if([urlF.text length]>0){
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            NSString *urls = [defaults objectForKey:@"urls"];
            NSString *names = [defaults objectForKey:@"names"];
            if(urls && [urls length]>1)
            {
                urls = [NSString stringWithFormat:@"%@,%@",urls,urlF.text];
                names = [NSString stringWithFormat:@"%@,%@",names,nameF.text];
            }else{
                urls = [NSString stringWithFormat:@"%@",urlF.text];
                names = [NSString stringWithFormat:@"%@",nameF.text];
            }
            [defaults setObject:urls forKey:@"urls"];
            [defaults setObject:names forKey:@"names"];
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            
            urlF.text = @"";
            nameF.text = @"";
            back.hidden = YES;
            
            [dataArr removeAllObjects];
            [self loadData];
            [table reloadData];
            
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"请输入地址"];
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ID = [NSString stringWithFormat:@"cell%ld",indexPath.row];
    
    NSMutableDictionary *dic = [dataArr objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.textLabel.text = [NSString stringWithFormat:@"%@:%@",[[dataArr objectAtIndex:indexPath.row] objectForKey:@"name"],[[dataArr objectAtIndex:indexPath.row] objectForKey:@"url"]];
        UIView *p = [[UIView alloc]initWithFrame:CGRectMake(m_w-30, 20, 10, 10)];
        p.tag = 100;
        p.layer.cornerRadius = 5.0;
        [cell addSubview:p];
        
        
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@",[[dataArr objectAtIndex:indexPath.row] objectForKey:@"name"],[[dataArr objectAtIndex:indexPath.row] objectForKey:@"url"]];
    
    UIView *p = [cell viewWithTag:100];
    if([[dic objectForKey:@"status"] intValue])
    {
        [p setBackgroundColor:[UIColor greenColor]];
    }else{
        [p setBackgroundColor:[UIColor whiteColor]];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataArr count];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
