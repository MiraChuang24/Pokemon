import Testing
@testable import Pokemon
internal import Combine

@Suite("FavoriteStorage 基本功能")
struct FavoriteStorageTests {
    let storage = FavoriteStorage.test

    @Test("add 新增收藏")
    func testAdd() async throws {
        await storage.remove(42)
        await storage.add(42)
        #expect(storage.isFavorite(42))
        #expect(storage.getAll().contains(42))
    }

    @Test("remove 移除收藏")
    func testRemove() async throws {
        await storage.add(100)
        await storage.remove(100)
        #expect(!storage.isFavorite(100))
        #expect(!storage.getAll().contains(100))
    }

    @Test("toggle 切換")
    func testToggle() async throws {
        await storage.remove(7)
        await storage.toggle(7)
        #expect(storage.isFavorite(7))
        await storage.toggle(7)
        #expect(!storage.isFavorite(7))
    }

    @Test("valuesPublisher 會送出變化")
    func testValuesPublisher() async throws {
        await storage.remove(999)
        var received: [Set<Int>] = []
        let cancellable = await storage.valuesPublisher.sink { received.append($0) }
        await storage.add(999)
        try await Task.sleep(nanoseconds: 100_000_000) // 等待 publisher 發送
        #expect(received.last?.contains(999) == true)
        cancellable.cancel()
    }
}
