/**
 * Copyright 2007-2009 Soggy Waffles
 * 
 * This file is part of Paintbrush.
 * 
 * Paintbrush is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Paintbrush is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Paintbrush.  If not, see <http://www.gnu.org/licenses/>.
 */


#import "SWBrushTool.h"

@implementation SWBrushTool

// Generates the path to be drawn to the image
- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	if (!path) {
		path = [NSBezierPath new];
		[path setLineWidth:2];
	}
	if (lineWidth == 1) {
		begin.x += 0.5;
		begin.y += 0.5;
		end.x += 0.5;
		end.y += 0.5;
	}
	[path moveToPoint:begin];
	[path lineToPoint:end];

	return path;
}

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)anImage 
						 secondImage:(NSBitmapImageRep *)secondImage 
						  mouseEvent:(SWMouseEvent)event
{	

	if (event == MOUSE_UP) {
		// No need to redraw
		[super resetRedrawRect];

		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:nil];
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:anImage]];
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];
		if (flags & NSAlternateKeyMask) {
			[backColor setStroke];
		} else {
			[frontColor setStroke];
		}
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
		[[NSColor redColor] setFill];
		[path closePath];
		[path fill];
		[NSGraphicsContext restoreGraphicsState];

		path = nil;
	} else {
		// Use the points clicked to build a redraw rectangle
		[super addRedrawRectFromPoint:point toPoint:savedPoint];

		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:anImage]];
		
		// The best way I can come up with to clear the image
		//SWClearImageRect(secondImage, redrawRect);
		
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];
		if (flags & NSAlternateKeyMask) {
			[backColor setStroke];	
		} else {
			[frontColor setStroke];
		}
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
		savedPoint = point;
		
		[NSGraphicsContext restoreGraphicsState];
	}
	return nil;
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		NSImage *customImage = [NSImage imageNamed:@"brush-cursor.png"];
		customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(1,14)];
	}
	return customCursor;
}

- (NSString *)description
{
	return @"Brush";
}

@end
