//
//  PlayerView.swift
//  BotwGuide
//
//  Created by Hawken Rives on 2/8/23.
//

import SwiftUI

struct PlayerList: View {
    /// Write access to the database
    @Environment(\.appDatabase) private var appDatabase

    /// The players in the list
    var players: [Player]

    /// The selected list items
    @State private var selection: Set<Player.ID> = []

    /// The search term
    @State private var searchTerm: String = ""

    /// The search tokens
    enum FruitToken: Identifiable, Hashable, CaseIterable {
        case apple
        case pear
        case banana
        var id: Self { self }
    }

    @State private var tokens: [FruitToken] = []

    /// Any search scopes
    enum ProductScope {
        case fruit
        case vegetable
    }

    @State private var scope: ProductScope = .fruit

    var body: some View {
        List(selection: $selection) {
            ForEach(players) { player in
                NavigationLink(
                    destination: PlayerEditionView(player: player)
                        .navigationBarTitle(player.name)
                ) {
                    PlayerRow(player: player)
                        // Don't animate player update
                        .animation(nil, value: player)
                }
            }
            .onDelete { offsets in
                let playerIds = offsets.compactMap { players[$0].id }
                try? appDatabase.deletePlayers(ids: playerIds)
            }
        }
        // Animate list updates
        .animation(.default, value: players)
        .listStyle(.plain)
        .searchable(text: $searchTerm, tokens: $tokens) {
            token in
            switch token {
            case .apple: Text("Apple")
            case .pear: Text("Pear")
            case .banana: Text("Bananna")
            }
        }
        .searchSuggestions {
            Text("🍎").searchCompletion(FruitToken.apple)
            Text("🍐").searchCompletion(FruitToken.pear)
            Text("🍌").searchCompletion(FruitToken.banana)
        }
        .searchScopes($scope) {
            Text("Fruit").tag(ProductScope.fruit)
            Text("Vegetable").tag(ProductScope.vegetable)
        }
    }
}

private struct PlayerRow: View {
    var player: Player

    var body: some View {
        Label {
            Text(player.name)
                .font(.body)

            Spacer()

            Text("\(player.score) points")
                .font(.body)
                .foregroundColor(.secondary)
        } icon: {
            //            Circle()
            //                .fill(player.profileColor)
            //                .frame(width: 44, height: 44, alignment: .center)
            //                .overlay(Text(player.initials))
            //                .foregroundColor(player.profileColor.readableForeground())
            Image(systemName: "person.3.sequence.fill")
                .symbolRenderingMode(.multicolor)
        }
    }
}

struct PlayerList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlayerList(players: [
                Player(id: 1, name: "Arthur", score: 100),
                Player(id: 2, name: "Barbara", score: 1000),
            ])
            .navigationTitle("Preview")
        }
    }
}
