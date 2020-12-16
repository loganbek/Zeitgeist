//
//  DeploymentsWidget.swift
//  DeploymentsWidget
//
//  Created by Daniel Eden on 01/08/2020.
//  Copyright © 2020 Daniel Eden. All rights reserved.
//

import WidgetKit
import SwiftUI

let exampleDeployment = Deployment(
  project: "Zeitgeist",
  id: "1",
  createdAt: Int(Date().timeIntervalSince1970 * 1000),
  state: .queued,
  urlString: "vercel.com",
  creator: DeploymentCreator(
    uid: "1",
    username: "example-user",
    email: "example@example.com"
  ),
  meta: nil
)

struct LatestDeploymentEntry: TimelineEntry {
  var date = Date()
  var deployment: Deployment
  var team: VercelTeam
}

struct DeploymentTimelineProvider: IntentTimelineProvider {
  typealias Entry = LatestDeploymentEntry
  typealias Intent = SelectTeamIntent
  
  let snapshotEntry = LatestDeploymentEntry(deployment: exampleDeployment, team: VercelTeam())
  
  func placeholder(in context: Context) -> Entry {
    
    return snapshotEntry
  }
  
  func getSnapshot(for configuration: SelectTeamIntent, in context: Context, completion: @escaping (Entry) -> Void) {
    let team = VercelTeam(id: configuration.team?.identifier ?? "-1", name: configuration.team?.displayString ?? "Personal")
    VercelFetcher.shared.settings.currentTeam = team.id
    
    VercelFetcher.shared.loadDeployments { (entries, _) in
      if entries != nil, let deployment = entries?[0] {
        let entry = LatestDeploymentEntry(deployment: deployment, team: team)
        completion(entry)
      } else {
        completion(snapshotEntry)
      }
    }
  }
  
  func getTimeline(for configuration: SelectTeamIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let team = VercelTeam(id: configuration.team?.identifier ?? "-1", name: configuration.team?.displayString ?? "Personal")
    VercelFetcher.shared.settings.currentTeam = team.id
    
    VercelFetcher.shared.loadDeployments { (entries, _) in
      if entries != nil, let deployment = entries?[0] {
        let entry = LatestDeploymentEntry(deployment: deployment, team: team)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
      } else {
        let timeline = Timeline(entries: [snapshotEntry], policy: .atEnd)
        completion(timeline)
      }
    }
  }
}

struct LatestDeploymentWidget: Widget {
  private let kind: String = "LatestDeploymentWidget"
  
  public var body: some WidgetConfiguration {
    IntentConfiguration(
      kind: kind,
      intent: SelectTeamIntent.self,
      provider: DeploymentTimelineProvider()
    ) { entry in
      LatestDeploymentWidgetView(config: entry)
    }
    .supportedFamilies([.systemSmall])
    .configurationDisplayName("Latest Deployment")
    .description("View the most recent Vercel deployment")
  }
}

@main
struct VercelWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
      LatestDeploymentWidget()
      RecentDeploymentsWidget()
    }
}

struct DeploymentsWidget_Previews: PreviewProvider {
  static var previews: some View {
    LatestDeploymentWidgetView(config: LatestDeploymentEntry(deployment: exampleDeployment, team: VercelTeam()))
      .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
