import { beforeEach, describe, expect, it, vi } from 'vitest'

const mockGet = vi.fn()
const mockPost = vi.fn()
const mockPut = vi.fn()
const mockDelete = vi.fn()

vi.mock('axios', () => {
  return {
    default: {
      create: vi.fn(() => ({
        get: mockGet,
        post: mockPost,
        put: mockPut,
        delete: mockDelete,
        interceptors: {
          response: {
            use: vi.fn(),
          },
        },
      })),
    },
  }
})

describe('documentApi', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('getAll should call api.get with empty path and return data', async () => {
    const fakeData = [{ id: 1, name: 'Doc' }]
    mockGet.mockResolvedValueOnce({ data: fakeData })

    const { documentApi } = await import('./documentApi')
    const result = await documentApi.getAll()

    expect(mockGet).toHaveBeenCalledWith('')
    expect(result).toEqual(fakeData)
  })

  it('upload should send multipart form data', async () => {
    mockPost.mockResolvedValueOnce({ data: { id: 2 } })

    const { documentApi } = await import('./documentApi')
    const file = new File(['content'], 'a.txt', { type: 'text/plain' })

    const result = await documentApi.upload('My Doc', file)

    expect(mockPost).toHaveBeenCalledTimes(1)
    const [path, formData, config] = mockPost.mock.calls[0]
    expect(path).toBe('')
    expect(formData).toBeInstanceOf(FormData)
    expect(config.headers['Content-Type']).toBe('multipart/form-data')
    expect(result).toEqual({ id: 2 })
  })

  it('update should send multipart form data to /{id}', async () => {
    mockPut.mockResolvedValueOnce({ data: { id: 3, name: 'Updated' } })

    const { documentApi } = await import('./documentApi')
    const file = new File(['updated'], 'b.txt', { type: 'text/plain' })

    const result = await documentApi.update(3, 'Updated', file)

    expect(mockPut).toHaveBeenCalledTimes(1)
    const [path, formData, config] = mockPut.mock.calls[0]
    expect(path).toBe('/3')
    expect(formData).toBeInstanceOf(FormData)
    expect(config.headers['Content-Type']).toBe('multipart/form-data')
    expect(result).toEqual({ id: 3, name: 'Updated' })
  })

  it('delete should call api.delete with /{id}', async () => {
    mockDelete.mockResolvedValueOnce({})

    const { documentApi } = await import('./documentApi')
    await documentApi.delete(9)

    expect(mockDelete).toHaveBeenCalledWith('/9')
  })

  it('download should create and click an anchor with blob url', async () => {
    mockGet.mockResolvedValueOnce({ data: new Blob(['abc'], { type: 'text/plain' }) })

    const createElementSpy = vi.spyOn(document, 'createElement')
    const appendSpy = vi.spyOn(document.body, 'appendChild')

    if (!window.URL.createObjectURL) {
      window.URL.createObjectURL = vi.fn()
    }
    if (!window.URL.revokeObjectURL) {
      window.URL.revokeObjectURL = vi.fn()
    }

    const createSpy = vi.spyOn(window.URL, 'createObjectURL').mockReturnValue('blob:test')
    const revokeSpy = vi.spyOn(window.URL, 'revokeObjectURL')

    const fakeLink = document.createElement('a')
    const clickSpy = vi.spyOn(fakeLink, 'click').mockImplementation(() => {})
    const setAttributeSpy = vi.spyOn(fakeLink, 'setAttribute')

    createElementSpy.mockReturnValue(fakeLink)

    const { documentApi } = await import('./documentApi')
    await documentApi.download(5, 'file.txt')

    expect(mockGet).toHaveBeenCalledWith('/5', { responseType: 'blob' })
    expect(createSpy).toHaveBeenCalled()
    expect(setAttributeSpy).toHaveBeenCalledWith('download', 'file.txt')
    expect(clickSpy).toHaveBeenCalled()
    expect(appendSpy).toHaveBeenCalled()
    expect(revokeSpy).toHaveBeenCalledWith('blob:test')
  })
})
