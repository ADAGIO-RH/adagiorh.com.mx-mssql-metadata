USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle](
	[IDTabuladorRelacionEvaluacionesObjetivosDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDTabuladorRelacionEvaluacionesObjetivos] [int] NOT NULL,
	[Nivel] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[MinimoEvaluaciones] [decimal](18, 4) NOT NULL,
	[MaximoEvaluaciones] [decimal](18, 4) NOT NULL,
	[MinimoObjetivos] [decimal](18, 4) NOT NULL,
 CONSTRAINT [Pk_NominatblTabuladorRelacionEvaluacionesObjetivosDetalle_IDTabuladorRelacionEvaluacionesObjetivosDetalle] PRIMARY KEY CLUSTERED 
(
	[IDTabuladorRelacionEvaluacionesObjetivosDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblTabuladorRelacionEvaluacionesObjetivosDetalle_IDTabuladorRelacionEvaluacionesObjetivos] ON [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle]
(
	[IDTabuladorRelacionEvaluacionesObjetivos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [Fk_NominatblTabuladorRelacionEvaluacionesObjetivosDetalle_NominatblTabuladorRelacionEvaluacionesObjetivos_ID] FOREIGN KEY([IDTabuladorRelacionEvaluacionesObjetivos])
REFERENCES [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos] ([IDTabuladorRelacionEvaluacionesObjetivos])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle] CHECK CONSTRAINT [Fk_NominatblTabuladorRelacionEvaluacionesObjetivosDetalle_NominatblTabuladorRelacionEvaluacionesObjetivos_ID]
GO
