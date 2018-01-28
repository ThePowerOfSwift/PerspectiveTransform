import Quick
import Nimble
import simd
@testable import PerspectiveTransform

class ProjectionSpec: QuickSpec {
    override func spec() {

        describe("general2DProjection") {
            context("scale and translate") {
                let expected = Matrix3x3Type([200.0/152, 0, 100,
                                              0, 200.0/122, 100,
                                              0, 0, 1])

                it("should match") {
                    let start = Perspective(CGRect(origin: CGPoint.zero, size: CGSize(width: 152, height: 122)))
                    let destination = Perspective(
                        CGRect(
                            origin: CGPoint(x: 100, y: 100),
                            size: CGSize(width: 200, height: 200)
                        )
                    )

                    let projection = start.projection(to: destination)
                    expect(projection) ≈ expected
                }

                context("concat") {
                    var expected3D: CATransform3D!
                    var translate3D: CATransform3D!
                    var scale3D: CATransform3D!

                    beforeEach {
                        expected3D = CATransform3D(expected.to3d())
                        translate3D = CATransform3DMakeTranslation(100, 100, 0)
                        scale3D = CATransform3DMakeScale(200.0/152, 200.0/122, 1)
                    }

                    it("should create 3D transformation scale + translate, in that order only") {
                        expect(CATransform3DConcat(scale3D, translate3D)) == expected3D
                        expect(CATransform3DConcat(translate3D, scale3D)) != expected3D
                    }

                    context("affine 2D") {
                        var scale2D: CGAffineTransform!
                        var translate2D: CGAffineTransform!
                        var expected2D: CGAffineTransform!

                        beforeEach {
                            scale2D = CATransform3DGetAffineTransform(scale3D)
                            translate2D = CATransform3DGetAffineTransform(translate3D)
                            expected2D = CATransform3DGetAffineTransform(expected3D)
                        }

                        it("should all be affine") {
                            let isAffine = [scale3D, translate3D, expected3D].map {CATransform3DIsAffine($0)}
                            expect(isAffine).to(allPass(beTrue()))
                        }

                        it("should create 2D affine tranformation") {
                            expect(scale2D.concatenating(translate2D)) == expected2D
                        }
                    }
                }
            }
        }
    }
}
