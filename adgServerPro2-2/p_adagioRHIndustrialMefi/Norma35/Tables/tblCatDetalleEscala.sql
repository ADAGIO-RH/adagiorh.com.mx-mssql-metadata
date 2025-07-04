USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblCatDetalleEscala](
	[IDCatDetalleEscala] [int] IDENTITY(1,1) NOT NULL,
	[IDCatEscala] [int] NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Valor] [int] NOT NULL,
 CONSTRAINT [Norma35tblCatDetalleEscala_IDCatDetalleEscala] PRIMARY KEY CLUSTERED 
(
	[IDCatDetalleEscala] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblCatDetalleEscala]  WITH CHECK ADD  CONSTRAINT [FK_Norma35TblCatEscalas_Norma35TblCatDetalleEscala_IDCatEscala] FOREIGN KEY([IDCatEscala])
REFERENCES [Norma35].[tblCatEscalas] ([IDCatEscala])
GO
ALTER TABLE [Norma35].[tblCatDetalleEscala] CHECK CONSTRAINT [FK_Norma35TblCatEscalas_Norma35TblCatDetalleEscala_IDCatEscala]
GO
