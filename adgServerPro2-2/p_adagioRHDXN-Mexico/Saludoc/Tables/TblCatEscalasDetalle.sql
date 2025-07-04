USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Saludoc].[TblCatEscalasDetalle](
	[IDCatEscalaDetalle] [int] NOT NULL,
	[IDCatEscala] [int] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Orden] [int] NOT NULL,
	[Valor] [int] NOT NULL,
 CONSTRAINT [PK_SaludocTblCatEscalasDetalle_IDCatEscalaDetalle] PRIMARY KEY CLUSTERED 
(
	[IDCatEscalaDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Saludoc].[TblCatEscalasDetalle]  WITH CHECK ADD  CONSTRAINT [FK_SaludocTblCatEscalas_SaludocTblCatEscalasDetalle_IDCatEscala] FOREIGN KEY([IDCatEscala])
REFERENCES [Saludoc].[tblCatEscalas] ([IDCatEscala])
GO
ALTER TABLE [Saludoc].[TblCatEscalasDetalle] CHECK CONSTRAINT [FK_SaludocTblCatEscalas_SaludocTblCatEscalasDetalle_IDCatEscala]
GO
