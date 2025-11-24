import Testing
@testable import Pokemon

@Suite("HomeViewModelTests")
struct HomeViewModelTests {

    @Test("fetchPokemons success populates pokemonItems")
    @MainActor
    func testFetchPokemonsSuccess() async {
        let mockAPI = MockPokeAPIClient()
        let vm = HomeViewModel(pokeAPIClient: mockAPI)

        await vm.fetchPokemons()
        #expect(vm.errorMessage == nil)
        #expect(vm.pokemonItems.count == mockAPI.mockPokemonList.results.count)
    }

    @Test("fetchAllTypes success populates typeItems")
    @MainActor
    func testFetchAllTypesSuccess() async {
        let mockAPI = MockPokeAPIClient()
        let vm = HomeViewModel(pokeAPIClient: mockAPI)

        await vm.fetchAllTypes()
        #expect(vm.errorMessage == nil)
        #expect(vm.typeItems.count == mockAPI.mockTypeList.results
            .filter { $0.id != PokemonType.unknownType.rawValue && $0.id != PokemonType.shadow.rawValue }
            .count)
    }

    @Test("fetchAllRegion success populates regionItems")
    @MainActor
    func testFetchAllRegionSuccess() async {
        let mockAPI = MockPokeAPIClient()
        let vm = HomeViewModel(pokeAPIClient: mockAPI)

        await vm.fetchAllRegion()
        #expect(vm.errorMessage == nil)
        #expect(vm.regionItems.count == mockAPI.mockRegionList.results.prefix(6).count)
    }
}
