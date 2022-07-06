//
//  GarmentViewModel.swift
//  LuluAssessement
//
//  Created by Ouss Elar on 7/1/22.
//

import Foundation


struct GarmentViewModel {
    
    func sortByDate(model: [GarmentItem]) -> [GarmentItem] {
        return model.sorted(by: { $0.dateAdded?.compare($1.dateAdded ?? Date.now) == .orderedDescending})
        
    }
    
    func sortByAlpha(model: [GarmentItem]) -> [GarmentItem] {
        return model.sorted(by: {$0.garmentName?.lowercased() ?? "" < $1.garmentName?.lowercased() ?? ""})
    }
}
