USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblHistorialDeCarpetasConUnArchivo](
	[IDHistorial] [int] IDENTITY(1,1) NOT NULL,
	[TipoReferencia] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDReferencia] [int] NOT NULL,
	[Path] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[File] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [Pk_ApptblHistorialDeCarpetasConUnArchivo_IDHistorial] PRIMARY KEY CLUSTERED 
(
	[IDHistorial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
