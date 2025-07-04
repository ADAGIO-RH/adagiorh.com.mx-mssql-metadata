USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatTipoJornada](
	[IDTipoJornada] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDSatTipoJornada] [int] NULL,
 CONSTRAINT [PK_tblCatTipoJornada_IDTipoJornada] PRIMARY KEY CLUSTERED 
(
	[IDTipoJornada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatTipoJornada]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatTiposJornada_RHTblCatTipoJornada_IDSatTipoJornada] FOREIGN KEY([IDSatTipoJornada])
REFERENCES [Sat].[tblCatTiposJornada] ([IDTipoJornada])
GO
ALTER TABLE [RH].[tblCatTipoJornada] CHECK CONSTRAINT [FK_SatTblCatTiposJornada_RHTblCatTipoJornada_IDSatTipoJornada]
GO
