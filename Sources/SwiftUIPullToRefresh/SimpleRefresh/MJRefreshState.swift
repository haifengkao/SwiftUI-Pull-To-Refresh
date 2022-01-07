//
//  MJRefreshState.swift
//  Pods
//
//  Created by Hai Feng Kao on 2021/7/24.
//  Copyright (c) 2021 Hai Feng Kao. All rights reserved.
//

/** 刷新控件的状态 */
enum MJRefreshState {
    /** 普通闲置状态 */
    case idle
    /** 松开就可以进行刷新的状态 */
    case pulling
    /** 即将刷新的状态 */
    case willRefresh
    /** 正在刷新中的状态 */
    case refresh
    /** 正在隱藏刷新進度 */
    case endingRefresh
    /** 所有数据加载完毕，没有更多的数据了 */
    case noMoreData
}
