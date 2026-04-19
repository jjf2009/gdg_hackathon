/**
 * Simple request validation helpers.
 */

/**
 * Validates that required body fields are present.
 * Returns a middleware function.
 *
 * Usage: router.post('/path', requireFields('name', 'crop_name'), handler);
 */
function requireFields(...fields) {
  return (req, res, next) => {
    const missing = fields.filter((f) => {
      const val = req.body[f];
      return val === undefined || val === null || val === '';
    });

    if (missing.length > 0) {
      return res.status(400).json({
        success: false,
        error: {
          message: `Missing required fields: ${missing.join(', ')}`,
        },
      });
    }

    next();
  };
}

/**
 * Validates that a UUID param is properly formatted.
 */
function validateUUID(paramName) {
  return (req, res, next) => {
    const value = req.params[paramName];
    const uuidRegex =
      /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

    if (!value || !uuidRegex.test(value)) {
      return res.status(400).json({
        success: false,
        error: { message: `Invalid ${paramName}: must be a valid UUID` },
      });
    }

    next();
  };
}

module.exports = { requireFields, validateUUID };
