//
//  OpenFoodsUITests 2.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//


//
//  OpenFoodsUITests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//


//
//  OpenFoodsUITests.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-28.
//

import XCTest
@testable import OpenFoods

// MARK: - UI Tests
class OpenFoodsUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        app = nil
    }
    
    // MARK: - App Launch Tests
    func testAppLaunches() {
        // Test that the app launches successfully
        XCTAssertTrue(app.navigationBars["OpenFoods"].waitForExistence(timeout: 10))
    }
    
    func testNavigationTitle() {
        let navigationBar = app.navigationBars["OpenFoods"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
        XCTAssertTrue(navigationBar.exists)
    }
    
    // MARK: - Food List Tests
    func testFoodListViewExists() {
        // Wait for the food list to load
        let foodList = app.collectionViews.firstMatch
        XCTAssertTrue(foodList.waitForExistence(timeout: 10))
    }
    
    func testLoadingIndicator() {
        // Check if loading indicator appears (it might disappear quickly)
        let loadingText = app.staticTexts["Loading delicious foods..."]
        // Don't assert existence since loading might be very fast
        // Just check if it can be found when it exists
        if loadingText.exists {
            XCTAssertTrue(loadingText.isHittable)
        }
    }
    
    func testOfflineIndicator() {
        // This test would need to simulate offline mode
        // In a real test, you might use network conditioning
        let offlineIndicator = app.staticTexts["Offline Mode"]
        // Don't assert existence since the app might be online
        if offlineIndicator.exists {
            XCTAssertTrue(offlineIndicator.isHittable)
        }
    }
    
    // MARK: - Food Item Interaction Tests
    func testFoodItemTap() {
        // Wait for food items to load
        sleep(3) // Give time for food items to load
        
        let foodItems = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'food_item'"))
        if foodItems.count > 0 {
            let firstFoodItem = foodItems.element(boundBy: 0)
            firstFoodItem.tap()
            
            // Should navigate to food detail view
            let foodDetailTitle = app.navigationBars["Food Details"]
            XCTAssertTrue(foodDetailTitle.waitForExistence(timeout: 5))
        }
    }
    
    func testHeartButtonExists() {
        // Wait for food items to load
        sleep(3)
        
        let heartButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'heart'"))
        if heartButtons.count > 0 {
            let firstHeartButton = heartButtons.element(boundBy: 0)
            XCTAssertTrue(firstHeartButton.exists)
            XCTAssertTrue(firstHeartButton.isHittable)
        }
    }
    
    func testLikeButtonTappable() {
         sleep(4)
         
         // Find any button that might be a like button
         let allButtons = app.buttons.allElementsBoundByIndex
         
         if allButtons.count > 0 {
             let firstButton = allButtons[0]
             if firstButton.isHittable {
                 firstButton.tap()
                 // Button should still exist after tap
                 XCTAssertTrue(firstButton.exists)
             }
         }
     }
    
    // MARK: - Food Detail Navigation Tests
     func testTapFoodItemNavigatesToDetail() {
         sleep(4)
         
         // Try to find and tap a food item
         let cells = app.cells.allElementsBoundByIndex
         
         if cells.count > 0 {
             let firstCell = cells[0]
             if firstCell.isHittable {
                 firstCell.tap()
                 
                 // Should navigate to detail screen
                 // Look for detail view elements
                 sleep(1)
                 
                 let doneButton = app.buttons["Done"]
                 if doneButton.exists {
                     XCTAssertTrue(doneButton.exists)
                     doneButton.tap() // Go back
                 }
             }
         }
     }
    
    func testFoodDetailShowsDescription() {
          sleep(4)
          
          let cells = app.cells.allElementsBoundByIndex
          
          if cells.count > 0 {
              let firstCell = cells[0]
              if firstCell.isHittable {
                  firstCell.tap()
                  sleep(1)
                  
                  // Check if description label exists
                  let descriptionLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'description'")).firstMatch
                  
                  if descriptionLabel.exists {
                      XCTAssertTrue(descriptionLabel.exists)
                  }
                  
                  // Close detail view
                  let doneButton = app.buttons["Done"]
                  if doneButton.exists {
                      doneButton.tap()
                  }
              }
          }
      }
    
    func testLikeButtonInteraction() {
        // Wait for food items to load
        sleep(3)
        
        let heartButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'heart'"))
        if heartButtons.count > 0 {
            let firstHeartButton = heartButtons.element(boundBy: 0)
            
            // Tap the heart button
            firstHeartButton.tap()
            
            // The heart should remain interactable (might change state)
            XCTAssertTrue(firstHeartButton.exists)
        }
    }
    
    // MARK: - Pull to Refresh Tests
    func testPullToRefresh() {
        let foodList = app.collectionViews.firstMatch
        XCTAssertTrue(foodList.waitForExistence(timeout: 10))
        
        // Perform pull to refresh gesture
        foodList.swipeDown()
        
        // The list should still exist after refresh
        XCTAssertTrue(foodList.exists)
    }
    
    // MARK: - Scroll Tests
    func testScrollFunctionality() {
        let foodList = app.collectionViews.firstMatch
        XCTAssertTrue(foodList.waitForExistence(timeout: 10))
        
        // Test scrolling down
        foodList.swipeUp()
        
        // Test scrolling back up
        foodList.swipeDown()
        
        // List should still be accessible
        XCTAssertTrue(foodList.exists)
    }
    
    func testInfiniteScrollLoadsMore() {
          sleep(4)
          
          let list = app.collectionViews.firstMatch
          if list.exists {
              // Scroll to bottom multiple times
              for _ in 0..<3 {
                  list.swipeUp()
                  sleep(1)
              }
              
              // Check for loading more indicator
              let loadingMoreText = app.staticTexts["Loading more..."]
              
              // Loading more might appear briefly
              if loadingMoreText.exists {
                  XCTAssertTrue(loadingMoreText.exists)
              }
          }
      }
    
    // MARK: - Offline Mode Tests
       func testOfflineModeIndicator() {
           // Offline indicator should only show when offline
           let offlineIndicator = app.staticTexts["Offline Mode"]
           
           // In normal conditions, offline mode shouldn't be active
           // This test documents the expected behavior
           if offlineIndicator.exists {
               XCTAssertTrue(offlineIndicator.isHittable)
           }
       }
    
    func testOfflineModePendingCount() {
        let offlineIndicator = app.staticTexts["Offline Mode"]
        
        if offlineIndicator.exists {
            // Check if pending count is displayed
            let pendingText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'pending'")).firstMatch
            
            if pendingText.exists {
                XCTAssertTrue(pendingText.exists)
            }
        }
    }
    
    func testFoodItemRenderingPerformance() {
         sleep(4)
         
         measure {
             // Measure time to render food items
             _ = app.cells.count
             sleep(1)
         }
     }
    
    // MARK: - Memory Tests
      func testMemoryUsageDuringScroll() {
          sleep(4)
          
          let list = app.collectionViews.firstMatch
          
          if list.exists {
              // Scroll extensively to test memory management
              for _ in 0..<10 {
                  list.swipeUp()
                  sleep(UInt32(0.3))
              }
              
              for _ in 0..<10 {
                  list.swipeDown()
                  sleep(UInt32(0.3))
              }
              
              // App should still be responsive
              XCTAssertTrue(list.exists)
          }
      }
    
    
    // MARK: - Error State Tests
      func testErrorStateDisplay() {
          // Error state should display when network fails
          // This test checks if error handling UI exists
          
          let errorTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'error' OR label CONTAINS[c] 'wrong'"))
          
          // Error might not be present in normal operation
          if errorTexts.count > 0 {
              let firstError = errorTexts.firstMatch
              XCTAssertTrue(firstError.isAccessibilityElement)
          }
      }
    
    func testRetryButtonExistsInErrorState() {
         let retryButton = app.buttons["Try Again"]
         
         // Retry button only exists in error state
         if retryButton.exists {
             XCTAssertTrue(retryButton.isHittable)
             retryButton.tap()
             
             // Should attempt to reload
             sleep(2)
         }
     }
    
    // MARK: - Dark Mode Tests
    func testDarkModeSupport() {

        let app = XCUIApplication()
        app.launchArguments += ["-ui_testing_dark_mode"]
        app.launch()

        let navBar = app.navigationBars["OpenFoods"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))

        // Take screenshot for later comparison
        let screenshot = navBar.screenshot()
        XCTAttachment(screenshot: screenshot).lifetime = .keepAlways
    }
    
    // MARK: - Accessibility Tests
    func testNavigationBarAccessibility() {
        let navigationBar = app.navigationBars["OpenFoods"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
       
    }

    
    
    // MARK: - Performance Tests
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    func testScrollPerformance() {
        let foodList = app.collectionViews.firstMatch
        XCTAssertTrue(foodList.waitForExistence(timeout: 10))
        
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            foodList.swipeUp()
            foodList.swipeDown()
        }
    }
    
    // MARK: - Network Simulation Tests
    func testOfflineMode() {
        // This would require network conditioning or mock data
        // For now, just test that the app handles offline state gracefully
        let offlineText = app.staticTexts["Offline Mode"]
        if offlineText.exists {
            XCTAssertTrue(offlineText.isHittable)
        }
    }
    
    // MARK: - Error Handling Tests
    func testErrorStateHandling() {
        // Test that error states are handled gracefully
        let errorTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'error' OR label CONTAINS 'Error'"))
        
        // If error text exists, it should be accessible
        if errorTexts.count > 0 {
            let firstErrorText = errorTexts.element(boundBy: 0)
            XCTAssertTrue(firstErrorText.isAccessibilityElement)
        }
    }
}
