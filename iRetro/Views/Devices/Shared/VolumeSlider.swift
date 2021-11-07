//
//  VolumeSlider.swift
//  SwiftUI-Jam-2020
//
//  Created by vladukha on 07.11.2021.
//

import SwiftUI
import AVFAudio

struct VolumeSlider: View {
	@State private var volHidden = true
	@State private var volume: Float = AVAudioSession.sharedInstance().outputVolume
	
	private func finEditing(){
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			withAnimation(.easeInOut) {
				volHidden = true
			}
		}
	}
	
	var body: some View {
		ZStack{
			if #available(iOS 15.0, *) {
				Slider(value: Binding(
					get: {
						self.volume
					},
					set: {(newValue) in
						self.volume = newValue
						MusicManager.shared.setVolume(newValue)
						
					}
				), onEditingChanged: {started in
					Haptics.rigid()
					if !started{
					finEditing()
					}
				})
					.tint(Color.gray)
					.hidden(volHidden)
					.transition(.move(edge: .trailing) )
			} else {
				Slider(value: Binding(
					get: {
						self.volume
					},
					set: {(newValue) in
						self.volume = newValue
						MusicManager.shared.setVolume(newValue)
					}
				), onEditingChanged: {started in
					Haptics.rigid()
					if !started{
					finEditing()
					}
				})
					.accentColor(Color.gray)
					.hidden(volHidden)
					.transition(.move(edge: .trailing) )
			}
		
			HStack{
				Spacer()
			Image(systemName: "chevron.left")
				
				.padding()
				.onTapGesture {
					withAnimation(.easeInOut, {
						volHidden.toggle()
					})
					
				}
				.hidden(!volHidden)
				.transition(.move(edge: .trailing) )
			}
	}
	}
}

struct VolumeSlider_Previews: PreviewProvider {
	static var previews: some View {
		VolumeSlider()
	}
}
