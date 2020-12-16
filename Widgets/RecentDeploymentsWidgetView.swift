//
//  RecentDeploymentsWidgetView.swift
//  iOS
//
//  Created by Daniel Eden on 03/10/2020.
//  Copyright © 2020 Daniel Eden. All rights reserved.
//

import SwiftUI

struct RecentDeploymentsWidgetView: View {
  var deployments: [Deployment]
  var team: VercelTeam
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Recent deployments")
          .font(.footnote).fontWeight(.semibold)
      
        if let currentTeam = team {
          Spacer()
          HStack(spacing: 2) {
            Image(systemName: "person.2.fill")
            Text(currentTeam.name)
          }.font(.footnote).foregroundColor(.secondary).imageScale(.small)
        }
      }
      
      Divider().padding(.bottom, 4)
      
      ForEach(deployments.prefix(6), id: \.self) { deployment in
        HStack(alignment: .top) {
          DeploymentStateIndicator(state: deployment.state, verbose: false, isWidget: true)
        
          VStack(alignment: .leading) {
            Text(deployment.meta?.commitMessage ?? "Manual Deployment")
              .fontWeight(.bold)
              .lineLimit(3)
              .foregroundColor(.primary)
            
            HStack {
              Text("\(deployment.project)")
                .foregroundColor(.secondary)
              
              Text(deployment.date, style: .relative)
                .foregroundColor(.secondary)
            }
          }
          
          Spacer()
        }
        .padding(.bottom, 4)
        .font(.footnote)
      }
      
      Spacer()
    }
    .padding()
    .background(Color(TColor.systemBackground))
    .background(LinearGradient(
                  gradient: Gradient(
                    colors: [Color(TColor.systemBackground), Color(TColor.secondarySystemBackground)]
                  ),
                  startPoint: .top,
                  endPoint: .bottom
    ))
  }
}

struct RecentDeploymentsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
      RecentDeploymentsWidgetView(
        deployments: [exampleDeployment, exampleDeployment],
        team: VercelTeam()
      )
    }
}
