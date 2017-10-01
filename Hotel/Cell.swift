//
//  Cell.swift
//  Hotel
//
//  Created by David Zhang on 9/30/17.
//  Copyright © 2017 David Zhang. All rights reserved.
//

import UIKit

class Cell:UITableViewCell
{
    @IBOutlet weak var itemImage:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var count:UILabel!
    @IBOutlet weak var plus:UIImageView!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        plus.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
    }
}
