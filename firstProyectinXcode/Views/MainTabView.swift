//
//  MainTabView.swift
//  firstProyectinXcode
//
//  Created by usuario on 10-11-24.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomePage()
                .tabItem {
                    Label("Inicio", systemImage: "house")
                }
            FeedPage()
                .tabItem {
                    Label("Feed", systemImage: "list.bullet")
                }
            EstadisticsPage()
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar")
                }
            ProfilePage()
                .tabItem {
                    Label("Perfil", systemImage: "person")
                }
        }
    }
}
