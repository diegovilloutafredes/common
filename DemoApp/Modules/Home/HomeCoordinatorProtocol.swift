//
//  HomeCoordinatorProtocol.swift
//  DemoApp
//

import Common

@MainActor
protocol HomeCoordinatorProtocol: AnyObject {
    func showDeclarativeUI()
    func showNetworking()
    func showStorage()
    func showAlerts()
    func showLocalAuth()
    func showExtensions()
    func showOnboarding()
    func showForms()
    func showLists()
    func showUtilities()
    func showCoordinatorDemo()
    func showImageLoading()
    func showTypography()
}
