USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InfoDir].[tblCatFiltrosItems](
	[IDFiltroItem] [int] NOT NULL,
	[IDTipoItem] [int] NULL,
	[IDTipoComponente] [int] NULL,
	[IsChecked] [bit] NULL,
	[LabelText] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreParametro] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreElemento] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MsjError] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IsRequired] [bit] NULL,
	[IsActive] [bit] NULL,
	[DisplayMember] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DisplayValue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DisplayMemberColor] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_InfoDirtblFiltrosItems_IDFiltroItem] PRIMARY KEY CLUSTERED 
(
	[IDFiltroItem] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InfoDir].[tblCatFiltrosItems]  WITH CHECK ADD  CONSTRAINT [FK_InfoDirtblFiltrosItems_InfoDirtblCatTipoComponentes_IDTipoComponente] FOREIGN KEY([IDTipoComponente])
REFERENCES [InfoDir].[tblCatTipoComponentes] ([IDTipoComponente])
GO
ALTER TABLE [InfoDir].[tblCatFiltrosItems] CHECK CONSTRAINT [FK_InfoDirtblFiltrosItems_InfoDirtblCatTipoComponentes_IDTipoComponente]
GO
ALTER TABLE [InfoDir].[tblCatFiltrosItems]  WITH CHECK ADD  CONSTRAINT [FK_InfoDirtblFiltrosItems_InfoDirtblCatTipoItems_IDTipoItem] FOREIGN KEY([IDTipoItem])
REFERENCES [InfoDir].[tblCatTipoItems] ([IDTipoItem])
GO
ALTER TABLE [InfoDir].[tblCatFiltrosItems] CHECK CONSTRAINT [FK_InfoDirtblFiltrosItems_InfoDirtblCatTipoItems_IDTipoItem]
GO
