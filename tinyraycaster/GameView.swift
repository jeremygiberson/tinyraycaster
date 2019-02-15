//
//  GameView.swift
//  tinyraycaster
//  https://github.com/ssloy/tinyraycaster/wiki/Part-1:-crude-3D-renderings
//

import Foundation
import Cocoa

class GameView: NSView {
    
    var mapBuffer: CGContext?
    var fpsBuffer: CGContext?
    
    override func draw(_ dirtyRect: CGRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            return
            
        }
        
        if mapBuffer == nil {
            mapBuffer = frameBuffer(width: 512, height: 512, like: ctx)
            gradient(context: mapBuffer!)
            drawMap(framebuffer: mapBuffer!)
            drawPlayer(framebuffer: mapBuffer!)
            //drawRay(x: player_x, y: player_y, a: player_a, framebuffer: mapBuffer!)
            drawFov(x: player_x, y: player_y, a: player_a, count: 512, framebuffer: mapBuffer!)
        }
        
        ctx.draw(mapBuffer!.makeImage()!, in: CGRect(x: 0, y: 0, width: 512, height: 512))
        
        draw3d(width: 328, height: 256, context: ctx)
    }
    
    private func draw3d(width:Int, height:Int, context:CGContext){
        fpsBuffer = frameBuffer(width: width, height: height, like: context)
        fpsBuffer?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        fpsBuffer?.fill(CGRect(x: 0, y: 0, width: width, height: height))
        drawFov3D(x: player_x, y: player_y, a: player_a, width: width, height: height, framebuffer: fpsBuffer!)
        context.draw(fpsBuffer!.makeImage()!, in: CGRect(x: 512, y: 0, width: width, height: height))
    }
    
    private func gradient(context:CGContext) {
        let width = context.width
        let height = context.height
        
        for y in 0..<height {
            for x in 0..<width {
                let r:CGFloat = (CGFloat(y)/CGFloat(height)); // varies between 0 and 255 as j sweeps the vertical
                let g:CGFloat = (CGFloat(x)/CGFloat(width)); // varies between 0 and 255 as i sweeps the horizontal
                let b:CGFloat = 0.0;
                context.setFillColor(red: r, green: g, blue: b, alpha: 1)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
    }
    
    private func drawMap(framebuffer:CGContext) {
        let width = framebuffer.width
        let height = framebuffer.height
        let cell_w = width/map_w;
        let cell_h = height/map_h;
        
        framebuffer.setFillColor(red: 0, green: 1, blue: 1, alpha: 1)
        
        for y in 0..<map_h {
            for x in 0..<map_w {
                let index = map.index(map.startIndex, offsetBy: (y * map_w) + x)
                if map[index] == " " {
                    continue
                }
                framebuffer.fill(CGRect(x: x * cell_w, y: y * cell_h, width: cell_w, height: cell_h))
            }
        }
    }
    
    private func drawPlayer(framebuffer:CGContext) {
        let cell_w = framebuffer.width/map_w
        let cell_h = framebuffer.height/map_h
        
        let pos_x = CGFloat(player_x * CGFloat(cell_w))
        let pos_y = CGFloat(player_y * CGFloat(cell_h))
        
        framebuffer.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        framebuffer.fill(CGRect(x: pos_x, y: pos_y, width: 5, height: 5))
    }
    
    private func drawRay(x:CGFloat, y:CGFloat, a:CGFloat, framebuffer:CGContext) {
        let cell_w = framebuffer.width/map_w
        let cell_h = framebuffer.height/map_h
        
        framebuffer.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        for t in stride(from: CGFloat(0.0), to: CGFloat(20.0), by: CGFloat(0.05)) {
            let cx = x + t*cos(a);
            let cy = y + t*sin(a);
            let offset = Int(Int(cx) + (Int(cy) * map_w))
            let index = map.index(map.startIndex, offsetBy: offset)
            if offset < map.count && map[index] != " " {
                break
            }
            
            let pix_x = cx * CGFloat(cell_w)
            let pix_y = cy * CGFloat(cell_h)
            
            framebuffer.fill(CGRect(x: pix_x, y: pix_y, width: 1, height: 1))
        }
    }
    
    private func drawFov(x:CGFloat, y:CGFloat, a:CGFloat, count:Int, framebuffer:CGContext) {
        for i in 0..<count {
            let angle = (a-(fov/2)) + fov*(CGFloat(i)/CGFloat(count));
            drawRay(x: x, y: y, a: angle, framebuffer: framebuffer)
        }
    }
    
    private func drawFov3D(x:CGFloat, y:CGFloat, a:CGFloat, width:Int, height:Int, framebuffer:CGContext) {
        let theta:CGFloat = fov/CGFloat(width)
        var angle = a-(fov/2.0)
        let cY:CGFloat = CGFloat(height)/2.0
        
        let pallete = [
            "0": CGColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1),
            "1": CGColor(red: 0.3, green: 0.4, blue: 0.3, alpha: 1),
            "2": CGColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1),
            "3": CGColor(red: 0.4, green: 0.3, blue: 0.3, alpha: 1)
        ]
        
        framebuffer.setFillColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        
        for i in 0..<width {
            let r = ray(x:x, y:y, a: angle)
            angle += theta
            if r.hit == false {
                continue
            }

            let wallHeight = CGFloat(height) / r.length!
            framebuffer.setFillColor(pallete[String(r.hitCell!)]!)
            framebuffer.fill(CGRect(x: i, y: Int(cY-(wallHeight/2)), width: 1, height: Int(wallHeight)))
        }
    }
    
    private func frameBuffer(width:Int, height:Int, like ctx:CGContext) -> CGContext {
        
        let buffer:CGContext? = CGContext(data: nil,
                                         width: width,
                                         height: height,
                                         bitsPerComponent: ctx.bitsPerComponent,
                                         bytesPerRow: (width * 8),
                                         space: ctx.colorSpace!,
                                         bitmapInfo: ctx.bitmapInfo.rawValue)
        return buffer!
    }
    
    private func ray(x:CGFloat, y:CGFloat, a:CGFloat) -> RayResult {
        for t in stride(from: CGFloat(0.0), to: CGFloat(20.0), by: CGFloat(0.05)) {
            let cx = x + t*cos(a);
            let cy = y + t*sin(a);
            let offset = Int(Int(cx) + (Int(cy) * map_w))
            let index = map.index(map.startIndex, offsetBy: offset)
            if offset < map.count && map[index] != " " {
                return RayResult(hit: true, hitX: cx, hitY: cy, length:t, hitCell: map[index])
            }
        }
        return RayResult(hit: false, hitX: nil, hitY: nil, length:nil, hitCell: nil)
    }
    
    let map =
        "0000222222220000" +
        "1              0" +
        "1      11111   0" +
        "1     0        0" +
        "0     0  1110000" +
        "0     3        0" +
        "0   10000      0" +
        "0   0   11100  0" +
        "0   0   0      0" +
        "0   0   1  00000" +
        "0       1      0" +
        "2       1      0" +
        "0       0      0" +
        "0 0000000      0" +
        "0              0" +
        "0002222222200000";
    let map_w = 16
    let map_h = 16
    
    var player_x:CGFloat = 3.456 // player x position
    var player_y:CGFloat = 2.345 // player y position
    var player_a:CGFloat = 1.523
    let fov:CGFloat = CGFloat.pi/3.0

}

struct RayResult {
    var hit:Bool
    var hitX:CGFloat?
    var hitY:CGFloat?
    var length:CGFloat?
    var hitCell:Character?
}

struct Map {
    let data:String
    let width:Int
    let height:Int
    
    func test(x:Int, y:Int) -> Character {
        let offset = Int(x + y * width)
        let index = data.index(data.startIndex, offsetBy: offset)
        return data[index]
    }
    func test(x:CGFloat, y:CGFloat) -> Character {
        return test(x: Int(x), y: Int(y))
    }
}
