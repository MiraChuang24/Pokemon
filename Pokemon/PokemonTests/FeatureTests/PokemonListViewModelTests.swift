import Testing
@testable import Pokemon

@Suite("PokemonListViewModelTests")
struct PokemonListViewModelTests {

    @Test("loadInitialData loads pokemons")
    @MainActor
    func testLoadInitialData() async {
        let mockAPI = MockPokeAPIClient()
        let vm = PokemonListViewModel(
            pokeAPIClient: mockAPI,
            favoriteStorage: .test
        )

        await vm.fetchPokemons(isInitial: true)
        #expect(vm.pokemons.count == mockAPI.mockPokemonList.results.count)
        #expect(vm.errorMessage == nil)
    }

    @Test("toggleFavorite updates favorites")
    @MainActor
    func testToggleFavorite() async {
        let mockAPI = MockPokeAPIClient()
        let storage = FavoriteStorage.test
        let vm = PokemonListViewModel(
            pokeAPIClient: mockAPI,
            favoriteStorage: storage
        )

        let pokemonID = 1
        vm.toggleFavorite(pokemonID: pokemonID)
        #expect(storage.isFavorite(pokemonID))
        vm.toggleFavorite(pokemonID: pokemonID)
        #expect(!storage.isFavorite(pokemonID))
    }

    @Test("refresh resets pokemons")
    @MainActor
    func testRefresh() async {
        let mockAPI = MockPokeAPIClient()
        let vm = PokemonListViewModel(
            pokeAPIClient: mockAPI,
            favoriteStorage: .test
        )

        await vm.fetchPokemons(isInitial: true)
        #expect(vm.pokemons.count > 0)
        await vm.refresh()
        #expect(vm.pokemons.count > 0)
    }
}
