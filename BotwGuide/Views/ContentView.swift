//
//  ContentView.swift
//  BotwGuide
//
//  Created by Hawken Rives on 2/8/23.
//

import GRDBQuery
import SwiftUI

/// The main application view
struct ContentView: View {
	/// Write access to the database
	@Environment(\.appDatabase) private var appDatabase

	/// The `players` property is automatically updated when the database changes
	@Query(PlayerRequest(ordering: .byScore)) private var players: [Player]

	/// We'll need to leave edit mode in several occasions.
	@State private var editMode = EditMode.inactive

	/// Tracks the presentation of the player creation sheet.
	@State private var newPlayerIsPresented = false

	// If you want to define the query on initialization, you will prefer:
	//
	// @Query<PlayerRequest> private var players: [Player]
	//
	// init(initialOrdering: PlayerRequest.Ordering) {
	//     _players = Query(PlayerRequest(ordering: initialOrdering))
	// }

	var body: some View {
		NavigationView {
			PlayerList(players: players)
				.navigationBarTitle(Text("Compendium"))
				.navigationBarItems(
					leading: HStack {
						EditButton()
						newPlayerButton
					},
					trailing: ToggleOrderingButton(
						ordering: $players.ordering,
						willChange: {
							// onChange(of: $players.wrappedValue.ordering)
							// is not able to leave the editing mode during
							// the animation of the list content.
							// Workaround: stop editing before the ordering
							// is changed, and the list content is updated.
							stopEditing()
						})
				)
				.toolbar { toolbarContent }
				.onChange(of: players) { players in
					if players.isEmpty {
						stopEditing()
					}
				}
				.environment(\.editMode, $editMode)
		}
	}

	private var toolbarContent: some ToolbarContent {
		ToolbarItemGroup(placement: .bottomBar) {
			Button {
				// Don't stopEditing() here because this is
				// performed `onChange(of: players)`
				try! appDatabase.deleteAllPlayers()
			} label: {
				Image(systemName: "trash").imageScale(.large)
			}

			Spacer()

			Button {
				stopEditing()
				try! appDatabase.refreshPlayers()
			} label: {
				Image(systemName: "arrow.clockwise").imageScale(.large)
			}

			Spacer()

			Button {
				stopEditing()
				// Perform 50 refreshes in parallel
				for _ in 0..<50 {
					DispatchQueue.global().async {
						try! AppDatabase.shared.refreshPlayers()
					}
				}
			} label: {
				Image(systemName: "tornado").imageScale(.large)
			}
		}
	}

	/// The button that presents the player creation sheet.
	private var newPlayerButton: some View {
		Button {
			stopEditing()
			newPlayerIsPresented = true
		} label: {
			Image(systemName: "plus")
		}
		.accessibility(label: Text("New Player"))
		.sheet(isPresented: $newPlayerIsPresented) {
			PlayerCreationView()
		}
	}

	private func stopEditing() {
		withAnimation {
			editMode = .inactive
		}
	}
}

private struct ToggleOrderingButton: View {
	@Binding var ordering: PlayerRequest.Ordering
	let willChange: () -> Void

	var body: some View {
		Menu {
			Picker("Sorting options", selection: $ordering) {
				Text("Score").tag(PlayerRequest.Ordering.byScore)
				Text("Name").tag(PlayerRequest.Ordering.byName)
			}
		} label: {
			Label("Sort", systemImage: "arrow.up.arrow.down")
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			// Preview the default, empty database
			ContentView()

			// Preview a database of random players
			ContentView().environment(\.appDatabase, .random())
		}
	}
}
