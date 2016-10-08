//
//  KTCameraPickerDelegate.swift
//  Camera Test
//
//  Created by Kunal Thacker on 08/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation

protocol KTCameraPickerDelegate {
    func cameraCancelTapped(VC: CameraViewController);
    func galleryDoneTapped(VC: CameraViewController);
    func galleryCancelTapped(VC: CameraViewController);
}
