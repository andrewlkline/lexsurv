import Foundation

struct AlignmentResult {
    var alignedA: [String]
    var alignedB: [String]
    var score: Double

    /// Normalized similarity in [-1, 1]. 1 means perfect match.
    var normalizedSimilarity: Double {
        guard !alignedA.isEmpty else { return 0 }
        return score / (FeatureWeight.maxSubScore * Double(max(alignedA.count, 1)))
    }
}

enum PhoneticAlignment {
    /// Tokenize an IPA string into segments. Combines a base character with
    /// any following combining diacritics/modifiers as a single segment.
    static func tokenize(_ s: String) -> [String] {
        let modifiers: Set<Character> = [
            "ʰ", "ʷ", "ʲ", "ˠ", "ˤ", "ː", "ˑ", "˘", "ⁿ", "ˡ",
            "̃", "̥", "̩", "̪", "̺", "̻", "̬", "̊", "͡", "͜"
        ]
        var out: [String] = []
        var current = ""
        for ch in s {
            if ch.isWhitespace { continue }
            if modifiers.contains(ch) {
                current.append(ch)
            } else {
                if !current.isEmpty {
                    out.append(current)
                }
                current = String(ch)
            }
        }
        if !current.isEmpty { out.append(current) }
        return out
    }

    /// Needleman-Wunsch global alignment over feature-weighted similarity.
    static func align(_ a: String, _ b: String) -> AlignmentResult {
        let A = tokenize(a)
        let B = tokenize(b)
        let n = A.count
        let m = B.count

        if n == 0 && m == 0 {
            return AlignmentResult(alignedA: [], alignedB: [], score: 0)
        }

        var dp = Array(repeating: Array(repeating: 0.0, count: m + 1), count: n + 1)
        var trace = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        // 0 = diag, 1 = up (gap in B), 2 = left (gap in A)

        for i in 1...max(n, 1) where n >= 1 {
            dp[i][0] = dp[i-1][0] + FeatureWeight.gapPenalty
            trace[i][0] = 1
        }
        if m >= 1 {
            for j in 1...m {
                dp[0][j] = dp[0][j-1] + FeatureWeight.gapPenalty
                trace[0][j] = 2
            }
        }

        if n >= 1 && m >= 1 {
            for i in 1...n {
                for j in 1...m {
                    let subScore = PhoneticFeatures.similarity(A[i-1], B[j-1])
                    let diag = dp[i-1][j-1] + subScore
                    let up = dp[i-1][j] + FeatureWeight.gapPenalty
                    let left = dp[i][j-1] + FeatureWeight.gapPenalty
                    if diag >= up && diag >= left {
                        dp[i][j] = diag; trace[i][j] = 0
                    } else if up >= left {
                        dp[i][j] = up; trace[i][j] = 1
                    } else {
                        dp[i][j] = left; trace[i][j] = 2
                    }
                }
            }
        }

        var i = n, j = m
        var outA: [String] = []
        var outB: [String] = []
        while i > 0 || j > 0 {
            let t = trace[i][j]
            if i > 0 && j > 0 && t == 0 {
                outA.append(A[i-1]); outB.append(B[j-1])
                i -= 1; j -= 1
            } else if i > 0 && (j == 0 || t == 1) {
                outA.append(A[i-1]); outB.append("-")
                i -= 1
            } else {
                outA.append("-"); outB.append(B[j-1])
                j -= 1
            }
        }

        return AlignmentResult(
            alignedA: outA.reversed(),
            alignedB: outB.reversed(),
            score: dp[n][m]
        )
    }

    /// Cluster a list of forms by a normalized-similarity threshold using
    /// single-linkage agglomerative clustering. Returns a list of cluster IDs,
    /// in the order of input forms, using single-letter labels (a, b, c, …, aa, ab, …).
    static func suggestGroupings(forms: [String], threshold: Double = 0.4) -> [String] {
        let n = forms.count
        guard n > 0 else { return [] }
        var parent = Array(0..<n)
        func find(_ x: Int) -> Int {
            var x = x
            while parent[x] != x { parent[x] = parent[parent[x]]; x = parent[x] }
            return x
        }
        func union(_ a: Int, _ b: Int) {
            let ra = find(a), rb = find(b)
            if ra != rb { parent[ra] = rb }
        }
        for i in 0..<n {
            for j in (i+1)..<n {
                let r = align(forms[i], forms[j])
                if r.normalizedSimilarity >= threshold {
                    union(i, j)
                }
            }
        }
        // Map each root to a label
        var rootLabel: [Int: String] = [:]
        var counter = 0
        var labels: [String] = []
        for i in 0..<n {
            let r = find(i)
            if let lbl = rootLabel[r] {
                labels.append(lbl)
            } else {
                let lbl = clusterLabel(counter)
                counter += 1
                rootLabel[r] = lbl
                labels.append(lbl)
            }
        }
        return labels
    }

    private static func clusterLabel(_ n: Int) -> String {
        // 0 -> "a", 1 -> "b", ..., 25 -> "z", 26 -> "aa", ...
        var n = n
        var s = ""
        repeat {
            let r = n % 26
            s = String(UnicodeScalar(UInt8(97 + r))) + s
            n = n / 26 - 1
        } while n >= 0
        return s
    }
}
