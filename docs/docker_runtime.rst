Docker runtime image
====================

Build an Intel/AMD64 image with pg_chameleon and its Python dependencies
installed:

.. code-block:: bash

   docker buildx build --platform linux/amd64 --load \
     -f Dockerfile.runtime \
     -t pg-chameleon-runtime:amd64 .

Run the installed CLI:

.. code-block:: bash

   docker run --rm --platform linux/amd64 pg-chameleon-runtime:amd64 chameleon.py --version

The image build runs ``chameleon.py --version`` and
``python -m unittest tests.test_tokenizer`` as a smoke test.

The Dockerfile pins ``setuptools<81`` because the current CLI imports
``pkg_resources``.
