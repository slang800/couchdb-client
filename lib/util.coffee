pickBy = require 'lodash/pickBy'
queryString = require 'querystring'

DB_NAME_RE = /^[a-z][a-z0-9_$()+/-]*$/

buildQueryString = (options) ->
  if options.groupLevel?
    options['group_level'] = options.groupLevel
    delete options.groupLevel

  if options.includeDocs?
    options['include_docs'] = options.includeDocs
    delete options.includeDocs

  if Array.isArray(options.endkey)
    options.endkey = JSON.stringify(options.endkey)

  if Array.isArray(options.startkey)
    options.startkey = JSON.stringify(options.startkey)

  # remove undefined vars because `queryString.stringify` doesn't like them
  options = pickBy(options, (value) -> value?)
  if Object.keys(options).length > 0
    '?' + queryString.stringify(options)
  else
    ''

###*
 * Check the given document for simple mistakes before sending to the server
 * @param {Object} doc
 * @return {undefined} No return value, only response will be a thrown Error
###
checkDoc = (doc) ->
  # TODO: add regex for document _id
  if doc._id? and typeof doc._id isnt 'string'
    throw new TypeError("doc._id must be a string")

checkStatus = (response) ->
  if response.status >= 200 and response.status < 300
    return response
  else
    error = new Error(response.statusText)
    error.response = response
    throw error

getRequestId = ({headers}) -> headers.get('x-couch-request-id')

module.exports = {
  DB_NAME_RE
  buildQueryString
  checkDoc
  checkStatus
  getRequestId
}
