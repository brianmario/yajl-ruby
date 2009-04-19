%module yajl
%{
#include <yajl/yajl_parse.h>
#include <yajl/yajl_gen.h>
%}

/** error codes returned from this interface */
typedef enum {
    /** no error was encountered */
    yajl_status_ok,
    /** a client callback returned zero, stopping the parse */
    yajl_status_client_canceled,
    /** The parse cannot yet complete because more json input text
     *  is required, call yajl_parse with the next buffer of input text.
     *  (pertinent only when stream parsing) */
    yajl_status_insufficient_data,
    /** An error occured during the parse.  Call yajl_get_error for
     *  more information about the encountered error */
    yajl_status_error
} yajl_status;

/** attain a human readable, english, string for an error */
const char * yajl_status_to_string(yajl_status code);

/** an opaque handle to a parser */
typedef struct yajl_handle_t * yajl_handle;

/** yajl is an event driven parser.  this means as json elements are
 *  parsed, you are called back to do something with the data.  The
 *  functions in this table indicate the various events for which
 *  you will be called back.  Each callback accepts a "context"
 *  pointer, this is a void * that is passed into the yajl_parse
 *  function which the client code may use to pass around context.
 *
 *  All callbacks return an integer.  If non-zero, the parse will
 *  continue.  If zero, the parse will be canceled and
 *  yajl_status_client_canceled will be returned from the parse.
 *
 *  Note about handling of numbers:
 *    yajl will only convert numbers that can be represented in a double
 *    or a long int.  All other numbers will be passed to the client
 *    in string form using the yajl_number callback.  Furthermore, if
 *    yajl_number is not NULL, it will always be used to return numbers,
 *    that is yajl_integer and yajl_double will be ignored.  If
 *    yajl_number is NULL but one of yajl_integer or yajl_double are
 *    defined, parsing of a number larger than is representable
 *    in a double or long int will result in a parse error.
 */
typedef struct {
    int (* yajl_null)(void * ctx);
    int (* yajl_boolean)(void * ctx, int boolVal);
    int (* yajl_integer)(void * ctx, long integerVal);
    int (* yajl_double)(void * ctx, double doubleVal);
    /** A callback which passes the string representation of the number
     *  back to the client.  Will be used for all numbers when present */
    int (* yajl_number)(void * ctx, const char * numberVal,
                        unsigned int numberLen);

    /** strings are returned as pointers into the JSON text when,
     * possible, as a result, they are _not_ null padded */
    int (* yajl_string)(void * ctx, const unsigned char * stringVal,
                        unsigned int stringLen);

    int (* yajl_start_map)(void * ctx);
    int (* yajl_map_key)(void * ctx, const unsigned char * key,
                         unsigned int stringLen);
    int (* yajl_end_map)(void * ctx);        

    int (* yajl_start_array)(void * ctx);
    int (* yajl_end_array)(void * ctx);        
} yajl_callbacks;

/** configuration structure for the generator */
typedef struct {
    /** if nonzero, javascript style comments will be allowed in
     *  the json input, both slash star and slash slash */
    unsigned int allowComments;
    /** if nonzero, invalid UTF8 strings will cause a parse
     *  error */
    unsigned int checkUTF8;
} yajl_parser_config;

/** allocate a parser handle
 *  \param callbacks  a yajl callbacks structure specifying the
 *                    functions to call when different JSON entities
 *                    are encountered in the input text.  May be NULL,
 *                    which is only useful for validation.
 *  \param config     configuration parameters for the parse.
 *  \param ctx        a context pointer that will be passed to callbacks.
 */
yajl_handle yajl_alloc(const yajl_callbacks * callbacks,
                                const yajl_parser_config * config,
                                const yajl_alloc_funcs * allocFuncs,
                                void * ctx);

/** free a parser handle */    
void yajl_free(yajl_handle handle);

/** Parse some json!
 *  \param hand - a handle to the json parser allocated with yajl_alloc
 *  \param jsonText - a pointer to the UTF8 json text to be parsed
 *  \param jsonTextLength - the length, in bytes, of input text
 */
yajl_status yajl_parse(yajl_handle hand,
                                const unsigned char * jsonText,
                                unsigned int jsonTextLength);

/** Parse any remaining buffered json.
 *  Since yajl is a stream-based parser, without an explicit end of
 *  input, yajl sometimes can't decide if content at the end of the
 *  stream is valid or not.  For example, if "1" has been fed in,
 *  yajl can't know whether another digit is next or some character
 *  that would terminate the integer token.
 *
 *  \param hand - a handle to the json parser allocated with yajl_alloc
 */
yajl_status yajl_parse_complete(yajl_handle hand);

/** get an error string describing the state of the
 *  parse.
 *
 *  If verbose is non-zero, the message will include the JSON
 *  text where the error occured, along with an arrow pointing to
 *  the specific char.
 *
 *  A dynamically allocated string will be returned which should
 *  be freed with yajl_free_error 
 */
unsigned char * yajl_get_error(yajl_handle hand, int verbose,
                                        const unsigned char * jsonText,
                                        unsigned int jsonTextLength);

/** free an error returned from yajl_get_error */
void yajl_free_error(yajl_handle hand, unsigned char * str);