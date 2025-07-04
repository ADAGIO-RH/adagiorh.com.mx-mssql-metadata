USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Transporte].[tblCatRutasDetalle](
	[IDRutaDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDRuta] [int] NULL,
	[Orden] [int] NULL,
	[Parada] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [PK_tblCatRutasDetalle_IDRutaDetalle] PRIMARY KEY CLUSTERED 
(
	[IDRutaDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Transporte].[tblCatRutasDetalle]  WITH CHECK ADD  CONSTRAINT [FK_TransportetblCatRutas_TransportetblCatRutaDetalle_IDRuta] FOREIGN KEY([IDRuta])
REFERENCES [Transporte].[tblCatRutas] ([IDRuta])
GO
ALTER TABLE [Transporte].[tblCatRutasDetalle] CHECK CONSTRAINT [FK_TransportetblCatRutas_TransportetblCatRutaDetalle_IDRuta]
GO
